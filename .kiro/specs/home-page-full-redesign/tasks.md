# Implementation Plan - Home Page Full Redesign

## Overview

Task list ini mengimplementasikan improvisasi lengkap Home Page QPARKIN agar konsisten dengan Activity Page dan Map Page, mengikuti design system yang telah ditetapkan.

## Tasks

- [x] 1. Update Content Section Background




  - Ubah background content section dari grey (#F5F5F5) ke white (Colors.white)
  - Hapus curved top corners pada content container
  - Pastikan seamless integration dengan header
  - _Requirements: 1.5_

- [x] 2. Redesign Parking Location Cards





  - [x] 2.1 Update card container styling


    - Ubah background ke Colors.white
    - Update border ke Colors.grey.shade200 dengan width 1px
    - Update shadow ke opacity 0.05 dengan blur 8px
    - Update padding ke 16px
    - _Requirements: 1.1, 1.2, 1.4_
  
  - [x] 2.2 Wrap card dengan Material + InkWell

    - Tambahkan Material wrapper dengan transparent color
    - Implementasi InkWell dengan onTap navigation ke Map Page
    - Set borderRadius 16px untuk ripple effect
    - _Requirements: 2.1, 2.2, 2.3, 14.3_
  
  - [x] 2.3 Redesign icon container

    - Update size ke 44x44px
    - Gunakan purple (#573ED1) background
    - Update icon size ke 20px
    - Pastikan border radius 12px
    - _Requirements: 8.1_
  
  - [x] 2.4 Implement distance badge

    - Buat badge dengan background Colors.grey.shade100
    - Padding 8px horizontal, 4px vertical
    - Border radius 8px
    - Font size 12px, weight w600
    - _Requirements: 3.2, 8.3_
  
  - [x] 2.5 Implement available slots badge

    - Buat badge dengan background Colors.green.shade50
    - Tambahkan dot indicator (6x6px, green.shade600)
    - Text color green.shade700
    - Font size 12px, weight w600
    - _Requirements: 3.3, 8.2_
  
  - [x] 2.6 Update text hierarchy

    - Name: 16px bold, Colors.black87
    - Address: 14px regular, Colors.grey.shade600, max 2 lines
    - Update spacing: 8px antar elements
    - _Requirements: 3.1, 3.4, 3.5, 5.1, 5.2, 5.3_
  
  - [x] 2.7 Add navigation arrow

    - Tambahkan arrow_forward_ios icon
    - Size 16px, color Colors.grey.shade400
    - Position di kanan bawah card
    - _Requirements: 8.4_
  

  - [x] 2.8 Remove "Booking Sekarang" button

    - Hapus ElevatedButton "Rute" dari card
    - Card hanya menampilkan informasi dan arrow
    - OnTap card navigasi ke Map Page
    - _Requirements: 14.2, 14.3_

- [x] 3. Implement Reusable Quick Action Card Component




  - [x] 3.1 Create _buildQuickActionCard method


    - Parameter: icon, label, color, onTap, useFontAwesome
    - Return Widget dengan consistent styling
    - Support both regular Icon dan FontAwesome
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [x] 3.2 Implement card container

    - Background Colors.white
    - Border dengan color.withOpacity(0.2), width 1.5px
    - Border radius 16px
    - Shadow opacity 0.05, blur 8px
    - Padding vertical 16px, horizontal 8px
    - _Requirements: 4.2, 4.4_
  
  - [x] 3.3 Implement icon container

    - Padding 12px
    - Background color.withOpacity(0.1)
    - Border radius 12px
    - Icon size 20px
    - _Requirements: 4.5_
  

  - [x] 3.4 Implement label text

    - Font size 12px, weight w600
    - Color Colors.black87
    - Text align center
    - Max 2 lines dengan ellipsis
    - _Requirements: 4.3_
  
  - [x] 3.5 Wrap dengan Material + InkWell

    - Material dengan transparent color
    - InkWell dengan onTap callback
    - Border radius 16px untuk ripple
    - _Requirements: 2.2, 2.5_

- [x] 4. Update Quick Actions Grid Layout





  - [x] 4.1 Update grid configuration


    - Change crossAxisCount dari 3 ke 4
    - Update crossAxisSpacing ke 12px
    - Update mainAxisSpacing ke 12px
    - Set childAspectRatio ke 0.85
    - _Requirements: 1.3, 4.1_
  
  - [x] 4.2 Update Quick Actions data


    - Booking: FontAwesome.squareParking, purple #573ED1
    - Peta: FontAwesome.mapLocationDot, blue #3B82F6
    - Tukar Poin: Icons.star, gold #FFA726
    - Riwayat: Icons.history, green #4CAF50
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 4.3 Implement navigation handlers


    - Booking: TODO placeholder
    - Peta: Navigate to /map
    - Tukar Poin: TODO placeholder
    - Riwayat: Navigate to /activity with initialTab: 1
    - _Requirements: 2.3_

- [x] 5. Implement Loading State





  - [x] 5.1 Create ShimmerLoading widget


    - Use Shimmer.fromColors package
    - Base color: Colors.grey.shade200
    - Highlight color: Colors.grey.shade100
    - Animation duration: 1500ms
    - _Requirements: 11.1, 11.3, 11.4_
  
  - [x] 5.2 Create skeleton card layout

    - Height 140px (same as actual card)
    - Border radius 16px
    - Show 3 skeleton cards
    - _Requirements: 11.2, 11.5_
  
  - [x] 5.3 Add loading state logic


    - Check if data is loading
    - Show shimmer when loading
    - Hide shimmer when data loaded
    - _Requirements: 11.1_

- [x] 6. Implement Empty State




  - [x] 6.1 Create EmptyState widget


    - Icon: Icons.location_off, size 48px
    - Icon color: Colors.grey.shade400
    - Title: "Tidak ada lokasi parkir tersedia"
    - Subtitle: "Coba lagi nanti atau cari di lokasi lain"
    - _Requirements: 12.1, 12.3, 12.5_
  
  - [x] 6.2 Add empty state logic


    - Check if data is empty
    - Show empty state when no data
    - Hide when data available
    - _Requirements: 12.1_

- [x] 7. Implement Error State




  - [x] 7.1 Create ErrorState widget


    - Icon: Icons.error_outline, size 48px, color #F44336
    - Title: "Terjadi Kesalahan"
    - Error message text
    - Retry button dengan icon refresh
    - _Requirements: 12.2, 12.4, 12.5_
  

  - [x] 7.2 Style retry button

    - Background color: #573ED1
    - Padding: 32px horizontal, 16px vertical
    - Border radius: 12px
    - Icon + label layout
    - _Requirements: 12.4_
  
  - [x] 7.3 Add error state logic

    - Check if error occurred
    - Show error state with message
    - Implement retry functionality
    - _Requirements: 12.2_

- [x] 8. Implement Micro Interactions




  - [x] 8.1 Add scale animation on card press


    - Use AnimatedScale or Transform.scale
    - Scale to 0.98 on press
    - Duration 150ms
    - Curve: Curves.easeInOut
    - _Requirements: 13.1, 13.2, 13.3, 13.5_
  
  - [x] 8.2 Refine InkWell ripple effects


    - Ensure splash color matches theme
    - Proper border radius on ripple
    - Smooth animation
    - _Requirements: 13.4_

- [x] 9. Update Typography Consistency





  - [x] 9.1 Update section titles


    - "Lokasi Parkir Terdekat": 20px bold
    - "Akses Cepat": 20px bold
    - Color: Colors.black87
    - _Requirements: 5.1_
  
  - [x] 9.2 Verify card titles


    - Location name: 16px bold
    - Color: Colors.black87
    - _Requirements: 5.2_
  
  - [x] 9.3 Verify body text


    - Address: 14px regular
    - Color: Colors.grey.shade600
    - _Requirements: 5.3_
  
  - [x] 9.4 Verify badge text


    - Distance, slots: 12px w600
    - Appropriate colors per badge type
    - _Requirements: 5.4, 5.5_

- [x] 10. Update Spacing Consistency






  - [x] 10.1 Verify content padding

    - Horizontal padding: 24px
    - Vertical padding: 24px top, 120px bottom
    - _Requirements: 6.1_
  

  - [x] 10.2 Verify card spacing

    - Gap between cards: 12px
    - Consistent throughout list
    - _Requirements: 6.2_
  

  - [x] 10.3 Verify section spacing

    - Gap between sections: 24px
    - Section title to content: 16px
    - _Requirements: 6.3_
  
  - [x] 10.4 Verify card internal padding


    - All cards: 16px padding
    - Icon to content: 16px gap
    - _Requirements: 6.4_
  

  - [x] 10.5 Verify icon container padding

    - All icon containers: 12px padding
    - Consistent across components
    - _Requirements: 6.5_

- [x] 11. Implement Accessibility Features




  - [x] 11.1 Verify touch targets


    - Quick Action cards: minimum 48dp
    - Parking Location cards: adequate with 16px padding
    - Retry button: 48dp height
    - _Requirements: 10.1, 10.2_
  
  - [x] 11.2 Verify color contrast


    - Primary text (black87): 13.6:1 ratio ✓
    - Secondary text (grey.shade600): 4.6:1 ratio ✓
    - Badge text: sufficient contrast
    - _Requirements: 10.3_
  
  - [x] 11.3 Add semantic labels


    - Meaningful labels for screen readers
    - Alternative text for icons
    - Proper widget semantics
    - _Requirements: 10.4, 10.5_

- [x] 12. Limit Nearby Locations Display




  - [x] 12.1 Limit list to 3 items


    - Use .take(3) or sublist(0, 3)
    - Show only 3 nearest locations
    - _Requirements: 14.1_
  

  - [x] 12.2 Verify "Lihat Semua" button




    - Navigate to Map Page
    - Proper styling and placement
    - _Requirements: 14.5_

- [x] 13. Testing and Validation





  - [x] 13.1 Run widget tests


    - Test component rendering
    - Test layout consistency
    - Test responsive behavior
    - _Requirements: All_
  
  - [x] 13.2 Test navigation flows


    - Home → Map navigation
    - Home → Activity navigation
    - "Lihat Semua" navigation
    - _Requirements: 2.3, 14.3, 14.5_
  

  - [x] 13.3 Test state transitions


    - Loading → Success
    - Loading → Error
    - Error → Retry → Success
    - _Requirements: 11.1, 12.2_
  
  - [x] 13.4 Test interactions


    - Card tap feedback
    - Button tap feedback
    - Ripple effects
    - Scale animations
    - _Requirements: 2.1, 2.2, 13.1_
  

  - [x] 13.5 Verify accessibility


    - Touch target sizes
    - Color contrast ratios
    - Screen reader compatibility
    - _Requirements: 10.1, 10.2, 10.3_
  
  - [x] 13.6 Performance testing



    - Animation smoothness (60fps)
    - Loading time
    - Memory usage
    - _Requirements: All_

- [x] 14. Final Polish and Documentation





  - [x] 14.1 Code cleanup


    - Remove unused code
    - Add code comments
    - Format code properly
    - _Requirements: All_
  
  - [x] 14.2 Update documentation


    - Document new components
    - Update component usage examples
    - Add migration notes
    - _Requirements: All_
  
  - [x] 14.3 Create visual comparison


    - Before/after screenshots
    - Highlight key improvements
    - Document design decisions
    - _Requirements: All_

## Notes

- All tasks are required for comprehensive implementation
- Follow the order of tasks for smooth implementation
- Each task builds on previous tasks
- Test after each major task completion
- Ensure no breaking changes to existing functionality
