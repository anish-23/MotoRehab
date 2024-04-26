MotoRehab is an application designed to assist in the rehabilitation process of individuals undergoing motor skill training. It provides a platform for users to upload videos of their exercises, analyze the movement data, and generate reports to track their progress over time.

Features
Video Upload: Users can upload videos of their exercises directly through the application.
Movement Analysis: The application analyzes the uploaded videos using optical flow techniques to assess factors such as smoothness, motion intensity, and motion complexity.
Report Generation: Based on the analysis results, MotoRehab generates detailed reports summarizing the user's performance and progress.
Data Visualization: The application provides visualizations, including time series graphs and metrics progress graphs, to help users understand their movement patterns and improvements.
Backend Server: The backend server handles video processing, analysis, and report generation tasks, ensuring seamless operation of the application.

Technologies Used
Frontend: Flutter framework for cross-platform mobile application development.
Backend: Flask, a lightweight web framework in Python, for handling server-side operations.
Data Analysis: OpenCV and NumPy libraries for optical flow analysis of video data.
Report Generation: ReportLab library for creating PDF reports with detailed analysis results.
Data Visualization: Matplotlib library for generating visualizations such as time series graphs and metrics progress graphs.

Installation
Install Dependencies:
For the frontend, ensure Flutter is installed and run flutter pub get in the project directory.
For the backend, ensure Python and Flask are installed.
Run the Application: Start the backend server by running python app.py. Run the Flutter application using flutter run.

Usage
Upload Video: Open the MotoRehab app and navigate to the 'Upload Video' section. Select the exercise video from your device and upload it.
Generate Report: After uploading videos for all exercises, navigate to the 'Generate Report' section and click the button to initiate report generation.
View Report: Once the report is generated, navigate to the 'View Report' section to access the detailed analysis results and visualizations.
