# Booking Feature - User Acceptance Testing Plan

## Overview
This document outlines the User Acceptance Testing (UAT) plan for the Booking feature. UAT should be conducted with real users to validate usability, identify UX issues, and verify all requirements are met.

---

## UAT Objectives

1. Validate that the booking feature meets user needs and expectations
2. Identify usability issues and pain points
3. Verify all functional requirements are working correctly
4. Gather feedback for improvements
5. Ensure accessibility compliance
6. Test real-world scenarios and edge cases

---

## Test Participants

### Target Users (5-10 participants)

**Profile 1: Frequent Parker (3 users)**
- Uses parking apps regularly
- Parks at malls 3+ times per week
- Tech-savvy
- Age: 25-40

**Profile 2: Occasional Parker (3 users)**
- Parks at malls 1-2 times per month
- Moderate tech skills
- Age: 30-50

**Profile 3: First-Time User (2 users)**
- Never used parking booking apps
- Basic tech skills
- Age: 40-60

**Profile 4: Accessibility User (2 users)**
- Uses screen readers or assistive technology
- Has visual, motor, or hearing impairments
- Any age

### Recruitment
- Internal employees (pilot test)
- Beta testing program participants
- Mall parking users (on-site recruitment)
- Social media call for testers

---

## Test Environment

### Setup Requirements
- **Devices:** Mix of Android and iOS devices (various screen sizes)
- **Network:** WiFi and mobile data (3G, 4G, 5G)
- **Locations:** Different physical locations for distance testing
- **Accounts:** Pre-created test accounts with vehicles registered
- **Backend:** Staging environment with test data

### Test Data
- 5 test malls with varying slot availability
- 10 test vehicles (different types)
- Various tariff structures
- Simulated booking conflicts
- Network failure scenarios

---

## Test Scenarios

### Scenario 1: First-Time Booking (Happy Path)

**Objective:** Complete a successful booking from start to finish

**Steps:**
1. Open app and navigate to Map
2. Browse and select a mall
3. Tap "Booking Sekarang"
4. Select a vehicle
5. Choose start time (1 hour from now)
6. Select duration (2 hours)
7. Review cost estimate
8. Check slot availability
9. Review booking summary
10. Confirm booking
11. View confirmation dialog with QR code
12. Navigate to Activity page
13. Verify booking appears

**Success Criteria:**
- [ ] All steps completed without confusion
- [ ] Booking created successfully
- [ ] QR code generated
- [ ] Booking visible in Activity page
- [ ] User understands next steps

**Metrics:**
- Time to complete: Target <3 minutes
- Number of errors: Target 0
- User satisfaction: Target 4/5 or higher

---

### Scenario 2: Booking with No Vehicles

**Objective:** Test the flow when user has no vehicles registered

**Steps:**
1. Login with account that has no vehicles
2. Navigate to booking page
3. Observe "Tambah Kendaraan" prompt
4. Tap "Tambah Kendaraan"
5. Add a vehicle
6. Return to booking
7. Complete booking

**Success Criteria:**
- [ ] Clear prompt to add vehicle
- [ ] Easy navigation to vehicle registration
- [ ] Smooth return to booking after adding vehicle
- [ ] User understands why vehicle is needed

---

### Scenario 3: Booking with Limited Slots

**Objective:** Test behavior when slots are limited or unavailable

**Steps:**
1. Select a mall with limited slots (3-5 available)
2. Observe yellow warning indicator
3. Proceed with booking
4. Select a mall with no slots
5. Observe red indicator and disabled button
6. Try alternative time slots
7. Complete booking when slots available

**Success Criteria:**
- [ ] Clear visual indicators for slot status
- [ ] Helpful messaging when slots unavailable
- [ ] Suggestions for alternative times
- [ ] User understands slot availability

---

### Scenario 4: Booking Modification Attempt

**Objective:** Test user understanding of booking limitations

**Steps:**
1. Complete a booking
2. Attempt to modify booking details
3. Observe current limitations
4. Cancel booking if needed
5. Create new booking

**Success Criteria:**
- [ ] User understands bookings cannot be modified
- [ ] Clear instructions for cancellation
- [ ] Easy to create new booking

---

### Scenario 5: Network Failure During Booking

**Objective:** Test error handling and recovery

**Steps:**
1. Start booking process
2. Simulate network failure (airplane mode)
3. Attempt to confirm booking
4. Observe error message
5. Restore network
6. Retry booking

**Success Criteria:**
- [ ] Clear error message displayed
- [ ] Retry option available
- [ ] Form data preserved
- [ ] Successful booking after retry

---

### Scenario 6: Booking Conflict

**Objective:** Test handling of existing active booking

**Steps:**
1. Create an active booking
2. Attempt to create another booking
3. Observe conflict error
4. Navigate to existing booking
5. Complete or cancel existing booking
6. Create new booking

**Success Criteria:**
- [ ] Clear conflict message
- [ ] Link to view existing booking
- [ ] User understands one booking limit

---

### Scenario 7: Cost Estimation Understanding

**Objective:** Verify users understand cost breakdown

**Steps:**
1. Start booking process
2. Select different durations
3. Observe cost changes
4. Read cost breakdown
5. Understand final cost calculation
6. Complete booking

**Success Criteria:**
- [ ] Cost breakdown is clear
- [ ] User understands first hour vs additional hours
- [ ] User understands estimate vs final cost
- [ ] No confusion about pricing

---

### Scenario 8: Accessibility Testing

**Objective:** Verify accessibility for users with disabilities

**Steps:**
1. Enable screen reader (TalkBack/VoiceOver)
2. Navigate through booking flow
3. Test all interactive elements
4. Verify focus order
5. Test with large text (200% scaling)
6. Test with high contrast mode

**Success Criteria:**
- [ ] All elements have semantic labels
- [ ] Logical focus order
- [ ] Screen reader announces all information
- [ ] Layout doesn't break with large text
- [ ] Sufficient contrast ratios

---

### Scenario 9: Multi-Device Testing

**Objective:** Test on various devices and screen sizes

**Devices to Test:**
- Small phone (320px width)
- Medium phone (375px width)
- Large phone (414px width)
- Tablet (768px width)

**Steps:**
1. Complete booking on each device
2. Test portrait and landscape orientations
3. Verify layout responsiveness
4. Check touch target sizes

**Success Criteria:**
- [ ] Layout adapts to all screen sizes
- [ ] No content overflow or truncation
- [ ] Touch targets are adequate
- [ ] Consistent experience across devices

---

### Scenario 10: Real-World Usage

**Objective:** Test in actual mall parking scenario

**Steps:**
1. Create booking while approaching mall
2. Navigate to mall
3. Use QR code at entrance
4. Park in assigned slot
5. Complete parking session
6. Exit using QR code
7. Review final cost

**Success Criteria:**
- [ ] Booking process quick enough for on-the-go use
- [ ] QR code scans successfully
- [ ] Clear instructions for entry/exit
- [ ] Final cost matches estimate (if within duration)

---

## Usability Metrics

### Quantitative Metrics

1. **Task Completion Rate**
   - Target: >95% for primary scenarios
   - Measure: % of users who complete task successfully

2. **Time on Task**
   - Target: <3 minutes for complete booking
   - Measure: Average time from mall selection to confirmation

3. **Error Rate**
   - Target: <5% error rate
   - Measure: Number of errors per task

4. **Success Rate**
   - Target: >90% first-attempt success
   - Measure: % completing without assistance

### Qualitative Metrics

1. **System Usability Scale (SUS)**
   - Target: Score >70 (above average)
   - 10-question standardized survey

2. **Net Promoter Score (NPS)**
   - Target: Score >50 (excellent)
   - "How likely are you to recommend this feature?"

3. **User Satisfaction**
   - Target: 4/5 or higher
   - 5-point Likert scale rating

---

## Test Questionnaire

### Pre-Test Questions

1. How often do you park at malls?
2. Have you used parking booking apps before?
3. What's your biggest pain point with mall parking?
4. What device do you primarily use?
5. Do you use any assistive technologies?

### During-Test Observations

1. Did the user hesitate at any point?
2. Did the user express confusion?
3. Did the user make any errors?
4. Did the user need assistance?
5. What was the user's emotional response?

### Post-Test Questions

1. How easy was it to complete the booking? (1-5)
2. Was the cost information clear? (1-5)
3. Did you feel confident about your booking? (1-5)
4. What did you like most about the feature?
5. What frustrated you the most?
6. What would you change or improve?
7. Would you use this feature regularly? (Yes/No/Maybe)
8. Would you recommend this to others? (1-10)
9. Any additional comments or suggestions?

### System Usability Scale (SUS)

Rate each statement from 1 (Strongly Disagree) to 5 (Strongly Agree):

1. I think I would like to use this feature frequently
2. I found the feature unnecessarily complex
3. I thought the feature was easy to use
4. I think I would need support to use this feature
5. I found the various functions well integrated
6. I thought there was too much inconsistency
7. I would imagine most people would learn this quickly
8. I found the feature very cumbersome to use
9. I felt very confident using the feature
10. I needed to learn a lot before I could use this

---

## Data Collection

### Methods

1. **Screen Recording**
   - Record all test sessions
   - Capture user interactions
   - Note hesitations and errors

2. **Think-Aloud Protocol**
   - Ask users to verbalize thoughts
   - Understand decision-making process
   - Identify confusion points

3. **Observation Notes**
   - Moderator takes detailed notes
   - Document non-verbal cues
   - Track time for each step

4. **Surveys**
   - Pre-test questionnaire
   - Post-test questionnaire
   - SUS and NPS scores

5. **Analytics**
   - Track completion rates
   - Measure time on task
   - Log errors and failures

---

## Analysis & Reporting

### Data Analysis

1. **Quantitative Analysis**
   - Calculate completion rates
   - Average time on task
   - Error frequency
   - SUS and NPS scores

2. **Qualitative Analysis**
   - Identify common themes
   - Categorize feedback
   - Prioritize issues
   - Extract quotes

3. **Severity Rating**
   - Critical: Prevents task completion
   - High: Causes significant difficulty
   - Medium: Causes minor difficulty
   - Low: Cosmetic or minor issue

### Report Structure

1. **Executive Summary**
   - Key findings
   - Overall success rate
   - Major issues
   - Recommendations

2. **Methodology**
   - Participants
   - Test scenarios
   - Data collection methods

3. **Results**
   - Quantitative metrics
   - Qualitative feedback
   - Issue list with severity

4. **Recommendations**
   - Prioritized improvements
   - Quick wins
   - Long-term enhancements

5. **Appendix**
   - Raw data
   - Participant quotes
   - Screenshots
   - Video clips

---

## Issue Tracking

### Issue Template

```
Issue ID: UAT-001
Severity: High
Category: Usability
Scenario: Scenario 1 - First-Time Booking
Description: Users confused about duration selection
Frequency: 7/10 users
Impact: Delays booking completion
Recommendation: Add tooltip explaining duration options
Priority: High
Status: Open
```

### Issue Categories

- Usability
- Functionality
- Performance
- Accessibility
- Content/Copy
- Visual Design
- Navigation

---

## Success Criteria

### Must-Have (Blockers)

- [ ] >90% task completion rate for primary scenarios
- [ ] <5% critical errors
- [ ] SUS score >70
- [ ] All accessibility requirements met
- [ ] No data loss or corruption

### Should-Have (High Priority)

- [ ] <3 minutes average booking time
- [ ] NPS score >50
- [ ] >4/5 user satisfaction
- [ ] <10% medium-severity issues

### Nice-to-Have (Medium Priority)

- [ ] <5% low-severity issues
- [ ] Positive user comments
- [ ] Feature requests for enhancements

---

## Timeline

### Week 1: Preparation
- Recruit participants
- Set up test environment
- Prepare test materials
- Train moderators

### Week 2: Testing
- Conduct UAT sessions (2-3 per day)
- Collect data
- Document issues
- Daily debriefs

### Week 3: Analysis
- Analyze quantitative data
- Analyze qualitative feedback
- Categorize and prioritize issues
- Create recommendations

### Week 4: Reporting
- Write UAT report
- Present findings to team
- Create action plan
- Schedule follow-up testing

---

## Follow-Up Actions

### Immediate (Week 5)
- Fix critical issues
- Implement quick wins
- Update documentation

### Short-Term (Weeks 6-8)
- Address high-priority issues
- Implement major improvements
- Conduct regression testing

### Long-Term (Months 2-3)
- Implement medium-priority enhancements
- Add requested features
- Conduct follow-up UAT

---

## Continuous Improvement

### Post-Launch Monitoring

1. **Analytics Tracking**
   - Booking completion rates
   - Drop-off points
   - Error rates
   - Time metrics

2. **User Feedback**
   - In-app feedback form
   - App store reviews
   - Support tickets
   - Social media mentions

3. **A/B Testing**
   - Test design variations
   - Optimize conversion
   - Improve UX

4. **Regular UAT**
   - Quarterly testing sessions
   - Test new features
   - Validate improvements

---

## Appendix

### A: Consent Form Template

```
QPARKIN User Acceptance Testing - Consent Form

I agree to participate in user testing for the QPARKIN Booking feature.
I understand that:
- My session will be recorded (screen and audio)
- My feedback will be used to improve the product
- My personal information will be kept confidential
- I can stop the session at any time
- I will receive [compensation] for my participation

Participant Name: _______________
Signature: _______________
Date: _______________
```

### B: Moderator Script

```
Introduction:
"Thank you for participating in our user testing. Today we're testing
the booking feature of the QPARKIN app. I'll ask you to complete some
tasks while thinking aloud. There are no right or wrong answers - we're
testing the app, not you. Please be honest with your feedback."

During Test:
- Encourage think-aloud
- Don't provide hints unless stuck
- Ask follow-up questions
- Take notes on observations

Closing:
"Thank you for your time and valuable feedback. Your input will help us
improve the app for all users."
```

### C: Test Data

```
Test Accounts:
- user1@test.com / Test123!
- user2@test.com / Test123!
- user3@test.com / Test123!

Test Malls:
- MALL001: Mega Mall (50 slots)
- MALL002: BCS Mall (10 slots)
- MALL003: Harbour Bay (0 slots)

Test Vehicles:
- B1234XYZ (Roda Empat)
- B5678ABC (Roda Dua)
```

---

## Contact

**UAT Coordinator:** [Name]
**Email:** uat@qparkin.com
**Phone:** +62 778 123 4567

---

**Document Version:** 1.0
**Last Updated:** November 26, 2025
**Next Review:** After UAT completion
