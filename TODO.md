# TODO: Replace Navigation in home_page.dart with CustomAnimatedNavBar

## Step 1: Update bottom_nav.dart
- Change navigation items to 3: Beranda (home), Parkir (directions_car), Profil (person)
- Update color scheme to purple to match app theme
- Adjust indicator position calculation for 3 items
- Remove special item handling

## Step 2: Update home_page.dart
- Remove _activeTab state variable
- Remove _buildNavItem method
- Replace Stack with SingleChildScrollView in Scaffold body
- Remove Positioned bottom navigation
- Add bottomNavigationBar: CustomAnimatedNavBar()
- Add import for bottom_nav.dart

## Step 3: Test and Verify
- Run the app to ensure navigation works
- Check design cleanliness and responsiveness
