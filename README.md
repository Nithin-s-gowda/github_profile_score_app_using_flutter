# Description
The GitHub Profile Score App allows users to evaluate their GitHub profile based on various metrics such as contributions, forks, organizations, gists, account age, and follower ratio. By entering their GitHub username and personal access token, users can view their profile score along with a visual representation in a bar chart.

# Packages Used
Flutter: The core framework for building the app.
fl_chart: Used to create beautiful charts to visualize the profile metrics.
http: Facilitates making HTTP requests to the GitHub API to fetch user data.
cupertino_icons: Provides iOS style icons for the application.
flutter_test: For testing purposes.
# Workflow
## User Input:
The app displays text fields for users to enter their GitHub username and personal access token.
## Data Fetching:
Upon pressing the "Get Score" button, the app sends a request to the GitHub API to retrieve user profile data.
## Data Processing:
The app processes the retrieved data to calculate a profile score based on predefined criteria.
## Displaying Results:
The app shows the user’s profile picture, name, bio, and calculated score.
A bar chart visualizes key metrics such as contributions, forks, organizations, gists, account age, and follower ratio.
## Error Handling:
If the API request fails or if inputs are invalid, the app provides appropriate error messages.



https://github.com/user-attachments/assets/cbc4b2c3-c279-4e7c-8343-7d9b31b2e5a1

