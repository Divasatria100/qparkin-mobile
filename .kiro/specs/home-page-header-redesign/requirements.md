# Requirements Document - Home Page Header Redesign

## Introduction

This specification defines the requirements for redesigning the Home Page header in the QPARKIN mobile application. The current header layout has visual imbalances, particularly in the placement and presentation of the 'Poin Saya' (My Points) section. The redesign must maintain consistency with the established visual language used in Activity Page and Map Page while improving the overall user experience and visual hierarchy.

## Glossary

- **Home Page**: The main landing screen of the QPARKIN app where users see their profile, points, nearby parking locations, and quick actions
- **Header Section**: The top portion of the Home Page containing user profile, points display, location selector, and search bar
- **Poin Saya (My Points)**: The rewards points system that displays the user's accumulated points
- **Visual Hierarchy**: The arrangement of design elements to show their order of importance
- **Design Consistency**: Maintaining uniform visual style across different pages (color theme, spacing, typography, shapes)
- **Glassmorphism**: A design technique using frosted glass effect with backdrop blur
- **Premium Card**: An elevated, visually distinct container that highlights important information

## Requirements

### Requirement 1: Visual Consistency Across Pages

**User Story:** As a user, I want the Home Page to have a consistent visual style with other pages so that the app feels cohesive and professional.

#### Acceptance Criteria

1. WHEN viewing the Home Page header, THE System SHALL use the same color palette as Activity Page and Map Page (primary purple #573ED1, gradients, white backgrounds)
2. WHEN viewing spacing and padding, THE System SHALL maintain consistent spacing rhythm (8dp grid system: 8, 12, 16, 24, 32px)
3. WHEN viewing typography, THE System SHALL use consistent font weights and sizes across all pages (bold titles: 20-22px, body text: 14-16px, labels: 12-14px)
4. WHEN viewing card components, THE System SHALL use consistent border radius (12-16px), shadows (subtle elevation), and white backgrounds
5. WHEN viewing interactive elements, THE System SHALL maintain consistent button styles and touch targets (minimum 48dp)

### Requirement 2: Improved Points Display

**User Story:** As a user, I want the points display to be more prominent and visually appealing so that I can easily see my rewards balance.

#### Acceptance Criteria

1. WHEN viewing the points section, THE System SHALL display points in a premium card design with clear visual separation from other elements
2. WHEN viewing the points value, THE System SHALL use large, bold typography (minimum 24px) for the numeric value
3. WHEN viewing the points label, THE System SHALL use a clear, readable label ("Poin Saya" or "My Points") with appropriate contrast
4. WHEN viewing the points icon, THE System SHALL include a star or reward icon that is visually consistent with the brand
5. WHEN the points card is displayed, THE System SHALL use subtle shadows or gradients to create depth and premium feel

### Requirement 3: Balanced Header Layout

**User Story:** As a user, I want the header layout to be visually balanced so that no single element feels cramped or overwhelming.

#### Acceptance Criteria

1. WHEN viewing the header, THE System SHALL organize elements in a logical visual hierarchy (location → greeting → profile/points → search)
2. WHEN viewing user profile information, THE System SHALL allocate appropriate space for avatar, name, and email without crowding
3. WHEN viewing the points display, THE System SHALL position it prominently without competing with the profile section
4. WHEN viewing on different screen sizes, THE System SHALL maintain proportional spacing and avoid text truncation
5. WHEN viewing the search bar, THE System SHALL provide adequate spacing from other elements (minimum 16px margin)

### Requirement 4: Modern Header Design

**User Story:** As a user, I want the header to look modern and premium so that the app feels high-quality and trustworthy.

#### Acceptance Criteria

1. WHEN viewing the header background, THE System SHALL use a gradient or solid color that creates visual interest
2. WHEN viewing glassmorphic elements, THE System SHALL apply backdrop blur effects consistently (location selector, notification button)
3. WHEN viewing the profile section, THE System SHALL use a modern card-based layout with rounded corners
4. WHEN viewing interactive elements, THE System SHALL provide visual feedback (ripple effects, state changes)
5. WHEN viewing the overall header, THE System SHALL create a clear separation between header and content using curved borders or shadows

### Requirement 5: Accessibility and Usability

**User Story:** As a user with accessibility needs, I want the header to be readable and usable so that I can access all features comfortably.

#### Acceptance Criteria

1. WHEN viewing text elements, THE System SHALL maintain minimum contrast ratio of 4.5:1 for normal text and 3:1 for large text
2. WHEN viewing interactive elements, THE System SHALL provide minimum touch target size of 48x48dp
3. WHEN using screen readers, THE System SHALL provide appropriate semantic labels for all interactive elements
4. WHEN viewing on small screens, THE System SHALL ensure all text remains readable without truncation
5. WHEN viewing the points value, THE System SHALL use sufficient font size (minimum 24px) for easy readability

### Requirement 6: Performance and Responsiveness

**User Story:** As a user, I want the header to load quickly and respond smoothly so that I can start using the app immediately.

#### Acceptance Criteria

1. WHEN the Home Page loads, THE System SHALL render the header within 300ms
2. WHEN applying backdrop blur effects, THE System SHALL maintain smooth 60fps scrolling performance
3. WHEN tapping interactive elements, THE System SHALL provide immediate visual feedback (within 100ms)
4. WHEN the page is scrolled, THE System SHALL maintain header stability without jank or layout shifts
5. WHEN switching between pages, THE System SHALL maintain consistent animation timing (200-300ms transitions)
