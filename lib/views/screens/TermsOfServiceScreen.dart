import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _hasAgreed = false;
  bool _isLoading = false;

  Future<void> _acceptTerms() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedTerms', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _rejectTerms() {
    // Close the app if terms are not accepted
    Navigator.of(context).popUntil((route) => route.isFirst);
    Future.delayed(Duration.zero, () => SystemNavigator.pop());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return WillPopScope(
      onWillPop: () async {
        _rejectTerms();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ব্যবহারের শর্তাবলী',style: TextStyle(color: Colors.white),),
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade50,
                      Colors.white,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            size: isTablet ? 48 : 36,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'স্বাগতম আমাদের ফ্রি ইবুক অ্যাপে!',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'অ্যাপটি ব্যবহারের আগে অনুগ্রহ করে শর্তাবলী পড়ুন',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('১. অ্যাপের ব্যবহার'),
                      _buildSectionContent(
                          'এই অ্যাপটি সম্পূর্ণ বিনামূল্যে ব্যবহারের জন্য। আপনি এখানে বিভিন্ন ক্যাটাগরির বই পড়তে পারবেন এবং ডাউনলোড করতে পারবেন। অ্যাপটি শুধুমাত্র ব্যক্তিগত ব্যবহারের জন্য।'),
                      const SizedBox(height: 16),
                      _buildSectionHeader('২. ব্যবহারকারীর দায়িত্ব'),
                      _buildBulletPoint(
                          '• আপনি অ্যাপে দেওয়া কোনো বই বাণিজ্যিক উদ্দেশ্যে ব্যবহার করবেন না।'),
                      _buildBulletPoint(
                          '• বই বা অ্যাপের কোনো কন্টেন্ট অননুমোদিতভাবে ডিস্ট্রিবিউট করবেন না।'),
                      _buildBulletPoint(
                          '• অ্যাপের কোনো অংশ মডিফাই বা রিভার্স ইঞ্জিনিয়ারিং করবেন না।'),
                      _buildBulletPoint(
                          '• অ্যাপটি ব্যবহারের সময় আপনি সকল স্থানীয় ও আন্তর্জাতিক আইন মেনে চলবেন।'),
                      const SizedBox(height: 16),
                      _buildSectionHeader('৩. গোপনীয়তা নীতি'),
                      _buildSectionContent(
                          'আমরা আপনার ব্যক্তিগত তথ্য সুরক্ষিত রাখতে প্রতিশ্রুতিবদ্ধ। অ্যাপটি ব্যবহারের সময় সংগ্রহ করা তথ্য শুধুমাত্র সেবা উন্নয়ন ও ব্যবহারকারীর অভিজ্ঞতা উন্নত করার জন্য ব্যবহৃত হবে।'),
                      const SizedBox(height: 16),
                      _buildSectionHeader('৪. কপিরাইট'),
                      _buildSectionContent(
                          'অ্যাপে থাকা সকল বই এবং কন্টেন্টের কপিরাইট সংশ্লিষ্ট লেখক ও প্রকাশকদের মালিকানাধীন। বইগুলো শুধুমাত্র শিক্ষামূলক ও ব্যক্তিগত পড়ার জন্য প্রদান করা হয়েছে। কোনো বইয়ের কপিরাইট লঙ্ঘন করা হলে, দয়া করে আমাদের জানান আমরা তা সরিয়ে দেব।'),
                      const SizedBox(height: 16),
                      _buildSectionHeader('৫. পরিবর্তনের অধিকার'),
                      _buildSectionContent(
                          'আমরা যেকোনো সময় এই শর্তাবলী পরিবর্তন করার অধিকার রাখি। পরিবর্তিত শর্তাবলী অ্যাপে প্রকাশিত হওয়ার পর থেকে তা কার্যকর বলে গণ্য হবে।'),
                      const SizedBox(height: 16),
                      _buildSectionHeader('৬. দায়বদ্ধতা'),
                      _buildSectionContent(
                          'এই অ্যাপে প্রদত্ত বই ও কন্টেন্টের জন্য আমরা সরাসরি দায়ী নই। বইয়ে প্রকাশিত মতামত লেখকের নিজস্ব মতামত, আমাদের নয়। বই পড়ার ফলে কোনো প্রকার ক্ষতির জন্য আমরা দায়বদ্ধ থাকব না।'),
                      const SizedBox(height: 24),
                      _buildAgreementCheckbox(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 18 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                            color: Colors.blue.shade700, width: 1.5),
                      ),
                      onPressed: _rejectTerms,
                      child: Text(
                        'প্রত্যাখ্যান',
                        style: TextStyle(
                          fontSize: (isTablet ? 20 : 18) / textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasAgreed
                            ? Colors.blue.shade700
                            : Colors.blue.shade300,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 18 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.blue.shade200,
                      ),
                      onPressed: _hasAgreed ? _acceptTerms : null,
                      child: Text(
                        'গ্রহণ করুন',
                        style: TextStyle(
                          fontSize: (isTablet ? 20 : 18) / textScale,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Colors.blue.shade600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.blue.shade700,
            ),
            child: Checkbox(
              value: _hasAgreed,
              onChanged: (value) {
                setState(() {
                  _hasAgreed = value ?? false;
                });
              },
              activeColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'আমি উপরের শর্তাবলী পড়েছি এবং তা মেনে নিচ্ছি',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}