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

    return WillPopScope(
      onWillPop: () async {
        _rejectTerms();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ব্যবহারের শর্তাবলী'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 40 : 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'স্বাগতম আমাদের ফ্রি ইবুক অ্যাপে! অ্যাপটি ব্যবহারের আগে অনুগ্রহ করে নিচের শর্তাবলী ভালোভাবে পড়ুন:',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                '১. অ্যাপের ব্যবহার:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                'এই অ্যাপটি সম্পূর্ণ বিনামূল্যে ব্যবহারের জন্য। আপনি এখানে বিভিন্ন ক্যাটাগরির বই পড়তে পারবেন এবং ডাউনলোড করতে পারবেন। অ্যাপটি শুধুমাত্র ব্যক্তিগত ব্যবহারের জন্য।',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '২. ব্যবহারকারীর দায়িত্ব:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                '• আপনি অ্যাপে দেওয়া কোনো বই বাণিজ্যিক উদ্দেশ্যে ব্যবহার করবেন না।\n'
                    '• বই বা অ্যাপের কোনো কন্টেন্ট অননুমোদিতভাবে ডিস্ট্রিবিউট করবেন না।\n'
                    '• অ্যাপের কোনো অংশ মডিফাই বা রিভার্স ইঞ্জিনিয়ারিং করবেন না।\n'
                    '• অ্যাপটি ব্যবহারের সময় আপনি সকল স্থানীয় ও আন্তর্জাতিক আইন মেনে চলবেন।',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '৩. গোপনীয়তা নীতি:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                'আমরা আপনার ব্যক্তিগত তথ্য সুরক্ষিত রাখতে প্রতিশ্রুতিবদ্ধ। অ্যাপটি ব্যবহারের সময় সংগ্রহ করা তথ্য শুধুমাত্র সেবা উন্নয়ন ও ব্যবহারকারীর অভিজ্ঞতা উন্নত করার জন্য ব্যবহৃত হবে।',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '৪. কপিরাইট:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                'অ্যাপে থাকা সকল বই এবং কন্টেন্টের কপিরাইট সংশ্লিষ্ট লেখক ও প্রকাশকদের মালিকানাধীন। বইগুলো শুধুমাত্র শিক্ষামূলক ও ব্যক্তিগত পড়ার জন্য প্রদান করা হয়েছে। কোনো বইয়ের কপিরাইট লঙ্ঘন করা হলে, দয়া করে আমাদের জানান আমরা তা সরিয়ে দেব।',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '৫. পরিবর্তনের অধিকার:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                'আমরা যেকোনো সময় এই শর্তাবলী পরিবর্তন করার অধিকার রাখি। পরিবর্তিত শর্তাবলী অ্যাপে প্রকাশিত হওয়ার পর থেকে তা কার্যকর বলে গণ্য হবে।',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '৬. দায়বদ্ধতা:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                'এই অ্যাপে প্রদত্ত বই ও কন্টেন্টের জন্য আমরা সরাসরি দায়ী নই। বইয়ে প্রকাশিত মতামত লেখকের নিজস্ব মতামত, আমাদের নয়। বই পড়ার ফলে কোনো প্রকার ক্ষতির জন্য আমরা দায়বদ্ধ থাকব না।',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _hasAgreed,
                    onChanged: (value) {
                      setState(() {
                        _hasAgreed = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'আমি উপরের শর্তাবলী পড়েছি এবং তা মেনে নিচ্ছি',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                      onPressed: _rejectTerms,
                      child: Text(
                        'প্রত্যাখ্যান',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.blueAccent.withOpacity(0.5); // Disabled color
                            }
                            return Colors.blueAccent; // Enabled color
                          },
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        elevation: WidgetStateProperty.all<double>(2),
                      ),
                      onPressed: _hasAgreed ? _acceptTerms : null,
                      child: Text(
                        'গ্রহণ করুন',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    ,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}