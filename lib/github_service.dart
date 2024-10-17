import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String _githubApiUrl = 'https://api.github.com';

  static Future<Map<String, dynamic>?> getGitHubProfileData(String username, String token) async {
    final userUrl = '$_githubApiUrl/users/$username';
    final reposUrl = '$_githubApiUrl/users/$username/repos';
    final eventsUrl = '$_githubApiUrl/users/$username/events';
    final orgsUrl = '$_githubApiUrl/users/$username/orgs';
    final gistsUrl = '$_githubApiUrl/users/$username/gists';

    try {
      // Fetch user data
      final userResponse = await http.get(
        Uri.parse(userUrl),
        headers: {'Authorization': 'token $token'},
      );

      // Fetch repositories data
      final reposResponse = await http.get(
        Uri.parse(reposUrl),
        headers: {'Authorization': 'token $token'},
      );

      // Fetch recent public events (to calculate contributions)
      final eventsResponse = await http.get(
        Uri.parse(eventsUrl),
        headers: {'Authorization': 'token $token'},
      );

      // Fetch organizations data
      final orgsResponse = await http.get(
        Uri.parse(orgsUrl),
        headers: {'Authorization': 'token $token'},
      );

      // Fetch gists data
      final gistsResponse = await http.get(
        Uri.parse(gistsUrl),
        headers: {'Authorization': 'token $token'},
      );

      if (userResponse.statusCode == 200 &&
          reposResponse.statusCode == 200 &&
          eventsResponse.statusCode == 200 &&
          orgsResponse.statusCode == 200 &&
          gistsResponse.statusCode == 200) {
        // Parse responses
        final userData = json.decode(userResponse.body);
        final reposData = json.decode(reposResponse.body) as List;
        final eventsData = json.decode(eventsResponse.body) as List;
        final orgsData = json.decode(orgsResponse.body) as List;
        final gistsData = json.decode(gistsResponse.body) as List;

        return {
          'userData': userData,
          'reposData': reposData,
          'eventsData': eventsData,
          'orgsData': orgsData,
          'gistsData': gistsData,
        };
      } else {
        print('Error fetching data from GitHub');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  static int calculateProfileScore(Map<String, dynamic> data) {
    int score = 0;

    final userData = data['userData'];
    final reposData = data['reposData'] as List;
    final eventsData = data['eventsData'] as List;
    final orgsData = data['orgsData'] as List;
    final gistsData = data['gistsData'] as List;

    // Scoring Criteria
    // 1. Contributions (commits, issues, pull requests) - max 20 points
    int contributions = eventsData.length.clamp(0, 30);
    score += contributions;

    // 2. Forked Repositories - max 10 points
    int forks = reposData.fold(0, (sum, repo) => sum + (repo['forks_count'] as int));
    score += forks.clamp(0, 10);

    // 3. Organizations - max 10 points
    int organizationsScore = orgsData.length.clamp(0, 10);
    score += organizationsScore;

    // 4. Gists - max 10 points
    int gistsScore = gistsData.length.clamp(0, 10);
    score += gistsScore;

    // 5. Account Age - max 10 points
    DateTime createdAt = DateTime.parse(userData['created_at']);
    int accountAgeYears = DateTime.now().difference(createdAt).inDays ~/ 365;
    int accountAgeScore = accountAgeYears.clamp(0, 10);
    score += accountAgeScore;

    // 6. Follower-to-Following Ratio - max 10 points
    int followers = userData['followers'];
    int following = userData['following'];
    double ratio = (following == 0) ? followers.toDouble() : followers / following;
    int ratioScore = ratio.clamp(0, 10).toInt();
    score += ratioScore;

    return score;
  }
}
