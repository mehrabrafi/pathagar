import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'TermsOfServiceScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "image": "assets/u1.png",
      "text": "হাজারো শিক্ষামূলক বই এখন এক অ্যাপে",
      "bgColor": Color(0xFFE3F2FD),
      "textColor": Color(0xFF0D47A1),
    },
    {
      "image": "assets/o3.png",
      "text": "অফলাইনে পড়ুন বিনামূল্যে!",
      "bgColor": Color(0xFFE8F5E9),
      "textColor": Color(0xFF2E7D32),
    },
    {
      "image": "assets/u2.png",
      "text": "নতুন বই নিয়মিত আপডেট – শেখার যাত্রায় থাকুন সবসময় এগিয়ে!",
      "bgColor": Color(0xFFFFF8E1),
      "textColor": Color(0xFFF57F17),
    },
  ];


  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _isLastPage = _pageController.page! >= onboardingData.length - 0.5;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: onboardingData[_currentIndex]["bgColor"],
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onboardingData[_currentIndex]["textColor"].withOpacity(0.1),
                ),
              ),
            ),

            Positioned(
              bottom: -100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onboardingData[_currentIndex]["textColor"].withOpacity(0.1),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: onboardingData[_currentIndex]["textColor"],
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final data = onboardingData[index];

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 40 : 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image with floating effect
                              Hero(
                                tag: 'onboarding-image-$index',
                                child: Container(
                                  height: isTablet ? 350 : 250,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CachedNetworkImage(
                                      imageUrl: data["image"],
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: data["textColor"],
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 40),

                              // Text with typewriter effect
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(0, 0.2),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  key: ValueKey(data["text"]),
                                  data["text"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isTablet ? 26 : 20,
                                    fontWeight: FontWeight.w700,
                                    color: data["textColor"],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: isTablet ? 40 : 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        // Custom dot indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onboardingData.length,
                                (index) => AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: _currentIndex == index ? 24 : 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentIndex == index
                                    ? onboardingData[_currentIndex]["textColor"]
                                    : onboardingData[_currentIndex]["textColor"].withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // Animated button
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: _isLastPage ? size.width * 0.8 : 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: _isLastPage ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: _isLastPage ? BorderRadius.circular(30) : null,
                            color: onboardingData[_currentIndex]["textColor"],
                            boxShadow: [
                              BoxShadow(
                                color: onboardingData[_currentIndex]["textColor"].withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: _isLastPage ? BorderRadius.circular(30) : null,
                              onTap: () {
                                if (_currentIndex < onboardingData.length - 1) {
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                  );
                                } else {
                                  _completeOnboarding();
                                }
                              },
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: _isLastPage
                                      ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ],
                                  )
                                      : Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}