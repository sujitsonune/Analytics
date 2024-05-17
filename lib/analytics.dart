import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    bool isTablet = screenWidth >= 600 && screenWidth <= 1600;

    int crossAxisCount = kIsWeb ? 2 : 1;

    double titleFontSize = kIsWeb ? 32 : (isTablet ? 32 : 26);

    double headFontSize = kIsWeb ? 26 : (isTablet ? 28 : 26);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/google.png',
              width: 52,
              height: 52,
            ),
            SizedBox(width: 8), // Spacing between icon and title
            Text(
              "Analytics Dashboard",
              style: TextStyle(
                fontSize: titleFontSize,
                fontFamily: 'GoogleSans',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('layout').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot document = documents[index];
                final String title = document['title'];
                final String title2 = document.id;

                return Container(
                  color: Colors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: 0.99,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: headFontSize,
                                fontFamily: 'GoogleSans',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Reduced height to 10
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('layout')
                            .doc(title2)
                            .collection('children')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final List<DocumentSnapshot> children =
                              snapshot.data!.docs;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 22, // Reduced spacing to 16
                              mainAxisSpacing: 20, // Reduced spacing to 16
                            ),
                            itemCount: children.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot child = children[index];
                              final int clicks = child['clicks'] ?? 'N/A';
                              final String name = child['title'] ?? 'N/A';
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.width * 0.3,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  border: Border.all(
                                    color: Colors.grey[500]?.withOpacity(0.4) ??
                                        Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: FractionallySizedBox(
                                        widthFactor: 1.0,
                                        heightFactor: 0.9,
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF4285F4)
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                "$clicks",
                                                style: TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontFamily: 'GoogleSans',
                                                  fontSize: headFontSize,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: 10), // Reduced height to 10
                                    Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "$name",
                                          style: TextStyle(
                                            fontFamily: 'GoogleSans',
                                            color: Colors.black,
                                            fontSize: headFontSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
