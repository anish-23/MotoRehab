import os
from flask import Flask, request, jsonify
import cv2
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use the 'Agg' backend (non-interactive)
import matplotlib.pyplot as plt
import pandas as pd
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, Image
from reportlab.lib.styles import getSampleStyleSheet
from datetime import datetime

app = Flask(__name__)

# Global variables to remember past results
exercise_metrics_history = {}

@app.route('/upload_video', methods=['POST'])
def upload_video():
    print("Received upload request")
    exercise = request.form.get('exercise')
    print("Exercise:", exercise)
    video_file = request.files.get('video')
    print("Video file:", video_file)
    if video_file:
        video_path = f"videos/{exercise}.mp4"
        video_file.save(video_path)
        print("Video saved successfully")
        analyze_video(video_path, exercise)
        return jsonify({"message": "Video uploaded and analyzed successfully."})
    else:
        return jsonify({"error": "No video file received."}), 400

@app.route('/get_report', methods=['GET'])
def get_report():
    exercise = request.args.get('exercise')
    report_path = f"reports/optical_flow_report_{exercise}.pdf"
    if os.path.exists(report_path):
        with open(report_path, 'rb') as file:
            response = file.read()
        return response, 200, {'Content-Type': 'application/pdf'}
    else:
        return jsonify({"error": f"Report for exercise {exercise} not found"}), 404

def extract_frames(video_path):
    cap = cv2.VideoCapture(video_path)
    frames = []
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        frames.append(frame)
    cap.release()
    return frames

def calculate_optical_flow(frames):
    flow_data = []
    prev_gray = cv2.cvtColor(frames[0], cv2.COLOR_BGR2GRAY)

    for frame in frames[1:]:
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        flow = cv2.calcOpticalFlowFarneback(prev_gray, gray, None, 0.5, 3, 15, 3, 5, 1.2, 0)
        flow_data.append(flow)
        prev_gray = gray

    return flow_data

def save_metrics_to_csv(video_name, smoothness_avg, motion_intensity_avg, motion_complexity_avg, exercise):
    current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    data = {
        'Video Name': [video_name],
        'Smoothness Average': [smoothness_avg],
        'Motion Intensity Average': [motion_intensity_avg],
        'Motion Complexity Average': [motion_complexity_avg],
        'Date and Time': [current_datetime]
    }
    df = pd.DataFrame(data)
    csv_path = f"metrics/metrics_{exercise}.csv"
    df.to_csv(csv_path, mode='a', header=not os.path.exists(csv_path), index=False)

def generate_report(video_name, exercise):
    global exercise_metrics_history

    # Create a PDF report
    doc = SimpleDocTemplate(f"reports/optical_flow_report_{exercise}.pdf", pagesize=letter)
    styles = getSampleStyleSheet()
    report_title = f"Optical Flow Analysis Report - Exercise {exercise}"
    report_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Report content
    report_content = []

    # Add title
    report_content.append(Paragraph(report_title, styles['Title']))

    # Add current date and time of exam
    report_content.append(Paragraph(f"Exam Date and Time: {report_date}", styles['Normal']))

    # Add previous date if available
    csv_path = f"metrics/metrics_{exercise}.csv"
    if os.path.exists(csv_path):
        df = pd.read_csv(csv_path)
        previous_date = df['Date and Time'].iloc[-1]
        report_content.append(Paragraph(f"Previous Exam Date: {previous_date}", styles['Normal']))

    # Add headings for metrics
    report_content.append(Paragraph("Metrics:", styles['Heading1']))

    # Add smoothness average
    smoothness_avg = np.mean(exercise_metrics_history[exercise]['Smoothness'])
    report_content.append(Paragraph(f"Smoothness Average: {smoothness_avg}", styles['Normal']))

    # Add motion intensity average
    motion_intensity_avg = np.mean(exercise_metrics_history[exercise]['Motion Intensity'])
    report_content.append(Paragraph(f"Motion Intensity Average: {motion_intensity_avg}", styles['Normal']))

    # Add motion complexity average
    motion_complexity_avg = np.mean(exercise_metrics_history[exercise]['Motion Complexity'])
    report_content.append(Paragraph(f"Motion Complexity Average: {motion_complexity_avg}", styles['Normal']))

    # Add graphs
    report_content.append(Paragraph("Graphs:", styles['Heading1']))

    # Add metrics progress graph
    """metrics_progress_img = f"reports/metrics_progress_{exercise}.png"
    if os.path.exists(metrics_progress_img):
        report_content.append(Paragraph("Movement Analysis Metrics Progress:", styles['Heading2']))
        report_content.append(Image(metrics_progress_img, width=400, height=300))
    else:
        report_content.append(Paragraph("No metrics progress graph available.", styles['Normal']))
    """
    # Plot time vs progress graph
    if os.path.exists(csv_path):
        df = pd.read_csv(csv_path)
        plt.figure(figsize=(8, 6))
        plt.plot(df['Date and Time'], df['Smoothness Average'], label='Smoothness Average')
        plt.plot(df['Date and Time'], df['Motion Intensity Average'], label='Motion Intensity Average')
        plt.plot(df['Date and Time'], df['Motion Complexity Average'], label='Motion Complexity Average')
        plt.xlabel('Date and Time')
        plt.ylabel('Average Metric Value')
        plt.title('Date and Time vs Average Metrics')
        plt.xticks(rotation=45)
        plt.legend()
        plt.grid(True)
        time_vs_metrics_img = f"reports/time_vs_metrics_{exercise}.png"
        plt.savefig(time_vs_metrics_img)  # Save plot as image
        plt.close()

        report_content.append(Paragraph("Date and Time vs Average Metrics Graph:", styles['Heading2']))
        report_content.append(Image(time_vs_metrics_img, width=400, height=300))
    else:
        report_content.append(Paragraph("No data available to plot graphs.", styles['Normal']))

    # Build the PDF report
    doc.build(report_content)

def analyze_video(video_path, exercise):
    global exercise_metrics_history

    frames = extract_frames(video_path)
    flow_data = calculate_optical_flow(frames)

    # Combine metrics for analysis
    smoothness_scores = [np.mean(np.sqrt(np.square(flow[..., 0]) + np.square(flow[..., 1]))) for flow in flow_data]
    motion_intensities = [np.mean(np.sqrt(np.square(flow[..., 0]) + np.square(flow[..., 1]))) for flow in flow_data]
    motion_complexities = [np.std(np.sqrt(np.square(flow[..., 0]) + np.square(flow[..., 1]))) for flow in flow_data]

    # Save metrics to history
    exercise_metrics_history[exercise] = {
        'Smoothness': smoothness_scores,
        'Motion Intensity': motion_intensities,
        'Motion Complexity': motion_complexities
    }

    # Calculate averages
    smoothness_avg = np.mean(smoothness_scores)
    motion_intensity_avg = np.mean(motion_intensities)
    motion_complexity_avg = np.mean(motion_complexities)

    # Save metrics to CSV
    video_name = os.path.basename(video_path)
    save_metrics_to_csv(video_name, smoothness_avg, motion_intensity_avg, motion_complexity_avg, exercise)

    # Generate report
    generate_report(video_name, exercise)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
