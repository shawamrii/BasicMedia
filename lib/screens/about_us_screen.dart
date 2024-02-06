import 'package:flutter/material.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../themedata/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperScreen extends StatefulWidget {
  @override
  _AboutDeveloperScreenState createState() => _AboutDeveloperScreenState();
}

class _AboutDeveloperScreenState extends State<AboutDeveloperScreen> {
  // Language Toggle - DE is default
  bool _isEnglish = false;

  // Method to launch email app with Mahmoud's email address
  void _launchEmailApp() async {
    Navigator.pushNamed(context, '/contact_us');

  }

  // Method to view Mahmoud's portfolio - replace with actual URL
  void _viewPortfolio() async {
    const portfolioUrl = 'www.linkedin.com/in/mahmoud-shawamreh';
    if (await canLaunchUrl(Uri.parse(portfolioUrl))) {
      await launchUrl(Uri.parse(portfolioUrl));
    } else {
      // Handle the error or inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the portfolio.'),
        ),
      );
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = _isEnglish ? 'About the Developer' : 'Über den Entwickler';
    String skillsTitle = _isEnglish ? 'Skills' : 'Fähigkeiten';
    String contactMe = _isEnglish ? 'Contact Me' : 'Kontaktiere Mich';
    String viewPortfolioButton = _isEnglish ? 'View Portfolio' : 'Portfolio Ansehen';

    String bio = _isEnglish
        ? 'A graduate in Computer Science (B.Sc.) from the Freie Universität Berlin, '
        'I specialize in object-oriented and functional programming with robust knowledge in algorithms '
        'and database management. My experience in developing cross-platform applications with Flutter, '
        'and as CTO at Ynerita where I developed an innovative platform, distinguishes my profile. '
        'I am dedicated to leveraging my technical knowledge and development skills in an innovative work environment.'
        : 'Als Absolvent der Informatik (B.Sc.) der Freien Universität Berlin, '
        'bin ich spezialisiert auf objektorientierte und funktionale Programmierung mit soliden Kenntnissen in Algorithmen '
        'und Datenbankmanagement. Meine Erfahrung in der Entwicklung von Cross-Platform-Anwendungen mit Flutter '
        'und als CTO bei Ynerita, wo ich eine innovative Plattform entwickelt habe, hebt mein Profil hervor. '
        'Ich strebe danach, mein technisches Wissen und meine Entwicklungsfähigkeiten in einer innovativen Arbeitsumgebung einzusetzen.';

    String skills = _isEnglish
        ? 'Flutter, Python, Java, SQL databases'
        : 'Flutter, Python, Java, SQL-Datenbank';

    return Scaffold(
      appBar: LuxuryAppBar(title: appBarTitle),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: LuxuryButton(
                label: _isEnglish ? 'DE' : 'EN',
                onPressed: _toggleLanguage,
              ),
            ),

            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('/home/shawamreh/basic_media/images/me.jpeg'), // Replace with actual image path
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Mahmoud Shawamreh',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: LuxuryTheme.dark,
              ),
            ),
            SizedBox(height: 10),
            Text(
              bio,
              style: TextStyle(
                fontSize: 16,
                color: LuxuryTheme.silver,
              ),
            ),
            SizedBox(height: 20),
            Text(
              skillsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: LuxuryTheme.gold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              skills,
              style: TextStyle(
                fontSize: 16,
                color: LuxuryTheme.silver,
              ),
            ),
            SizedBox(height: 20),
            LuxuryButton(
              label: contactMe,
              onPressed: _launchEmailApp,
            ),
            SizedBox(height: 20),
            LuxuryButton(
              label: viewPortfolioButton,
              onPressed: _viewPortfolio,
            ),

          ],
        ),
      ),
    );
  }
}
