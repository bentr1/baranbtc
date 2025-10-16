import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app.dart';
import '../config/app_config.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Kripto Analizi',
      description: 'Binance.com\'dan günlük mum verilerini analiz edin ve profesyonel teknik analiz sonuçları alın.',
      icon: Icons.analytics,
      color: AppConfig.primaryColor,
    ),
    OnboardingPage(
      title: 'Anlık Bildirimler',
      description: 'Önemli fiyat hareketleri ve analiz sinyalleri için anında bildirim alın.',
      icon: Icons.notifications_active,
      color: AppConfig.successColor,
    ),
    OnboardingPage(
      title: 'Güvenli Erişim',
      description: 'MFA ve biyometrik kimlik doğrulama ile güvenli erişim sağlayın.',
      icon: Icons.security,
      color: AppConfig.warningColor,
    ),
    OnboardingPage(
      title: 'Çoklu Dil Desteği',
      description: 'Türkçe, İngilizce, Fransızca ve Almanca dillerinde kullanın.',
      icon: Icons.language,
      color: AppConfig.infoColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConfig.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConfig.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    // TODO: Mark onboarding as completed
    context.go('/login');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Atla',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            
            // Navigation
            _buildNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60.r),
            ),
            child: Icon(
              page.icon,
              size: 60.w,
              color: page.color,
            ),
          ),
          
          SizedBox(height: 48.h),
          
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16.h),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: Text(
                'Geri',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          
          // Page Indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                width: 12.w,
                height: 12.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Next/Finish Button
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              _currentPage == _pages.length - 1 ? 'Başla' : 'İleri',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
