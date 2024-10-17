import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
import 'github_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Profile Score',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GitHubProfileScoreScreen(),
    );
  }
}

class GitHubProfileScoreScreen extends StatefulWidget {
  @override
  _GitHubProfileScoreScreenState createState() => _GitHubProfileScoreScreenState();
}

class _GitHubProfileScoreScreenState extends State<GitHubProfileScoreScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  String? _scoreMessage;
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;

  Future<void> _getProfileScore() async {
    final username = _usernameController.text;
    final token = _tokenController.text;

    if (username.isEmpty || token.isEmpty) {
      setState(() {
        _scoreMessage = 'Please enter both the username and personal access token.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = await GitHubService.getGitHubProfileData(username, token);
    if (data != null) {
      final score = GitHubService.calculateProfileScore(data);
      setState(() {
        _profileData = data;
        _scoreMessage = 'GitHub Profile Score for $username: $score/70';
      });
    } else {
      setState(() {
        _scoreMessage = 'Failed to fetch data. Please check the username and token.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Profile Score'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter GitHub Username',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Enter GitHub Personal Access Token',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getProfileScore,
              child: Text('Get Score'),
            ),
            SizedBox(height: 20),
            if (_scoreMessage != null) Text(_scoreMessage!),
            if (_profileData != null) ...[
              SizedBox(height: 20),
              CircleAvatar(
                backgroundImage: NetworkImage(_profileData!['userData']['avatar_url']),
                radius: 40,
              ),
              SizedBox(height: 10),
              Text(
                _profileData!['userData']['name'] ?? 'No Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(_profileData!['userData']['bio'] ?? 'No Bio'),
              SizedBox(height: 20),
              _buildScoreChart(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 50,
          barGroups: [
            _buildBarGroup(0, 'Contributions', _profileData!['eventsData'].length),
            _buildBarGroup(1, 'Forks', _profileData!['reposData'].length),
            _buildBarGroup(2, 'Organizations', _profileData!['orgsData'].length),
            _buildBarGroup(3, 'Gists', _profileData!['gistsData'].length),
            _buildBarGroup(4, 'Account Age', DateTime.now().difference(DateTime.parse(_profileData!['userData']['created_at'])).inDays ~/ 365),
            _buildBarGroup(5, 'Followers', _profileData!['userData']['followers']),
          ],
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitles: (value) {
                return (value.toInt() + 1).toString(); // Shows 1, 2, 3, etc.
              },
            ),
            leftTitles: SideTitles(showTitles: true),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String title;
                double value;

                switch (groupIndex) {
                  case 0:
                    title = 'Contributions';
                    value = _profileData!['eventsData'].length.toDouble();
                    break;
                  case 1:
                    title = 'Forks';
                    value = _profileData!['reposData'].length.toDouble();
                    break;
                  case 2:
                    title = 'Organizations';
                    value = _profileData!['orgsData'].length.toDouble();
                    break;
                  case 3:
                    title = 'Gists';
                    value = _profileData!['gistsData'].length.toDouble();
                    break;
                  case 4:
                    title = 'Account Age';
                    value = (DateTime.now().difference(DateTime.parse(_profileData!['userData']['created_at'])).inDays ~/ 365).toDouble();
                    break;
                  case 5:
                    title = 'Followers';
                    value = _profileData!['userData']['followers'].toDouble();
                    break;
                  default:
                    title = '';
                    value = 0;
                }

                return BarTooltipItem(
                  '$title\n$value',
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, String title, int value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: value.toDouble(),
          colors: [Colors.blue],
          width: 20,
        ),
      ],
    );
  }
}
