# Implementation Plan - Vehicle Edit Feature

- [x] 1. Modify VehicleSelectionPage to support dual-mode operation





  - Add constructor parameters `isEditMode` and `vehicle` to VehicleSelectionPage
  - Add state variables `_isEditMode`, `_editingVehicle`, and `_originalPhotoUrl`
  - Implement mode detection in `initState()`
  - _Requirements: 1.1, 1.5_

- [x] 2. Implement data prefilling for edit mode





  - [x] 2.1 Create `_prefillFormData()` method


    - Prefill text controllers (brand, type, plate, color)
    - Set selected vehicle type
    - Set selected vehicle status
    - Store original photo URL
    - _Requirements: 1.2_
  
  - [x] 2.2 Write property test for data prefilling






    - **Property 1: Edit mode initialization with data prefilling**
    - **Validates: Requirements 1.1, 1.2**

- [x] 3. Implement read-only field rendering for edit mode





  - [x] 3.1 Create `_buildReadOnlyVehicleType()` method


    - Display vehicle type with grey background
    - Add lock icon to indicate read-only state
    - Disable interaction
    - _Requirements: 2.1, 2.3_
  
  - [x] 3.2 Modify `_buildVehicleTypeSection()` to conditionally render


    - Return read-only widget if edit mode
    - Return interactive grid if add mode
    - _Requirements: 2.1, 2.5_
  
  - [x] 3.3 Modify plate number TextField to be read-only in edit mode


    - Set `enabled: !_isEditMode`
    - Add grey background when disabled
    - Add lock icon suffix when disabled
    - _Requirements: 2.2, 2.4_
  
  - [ ]* 3.4 Write property test for read-only field immutability
    - **Property 2: Mode-specific field editability**
    - **Validates: Requirements 2.3, 2.4**

- [x] 4. Update header and button text based on mode





  - [x] 4.1 Modify header text


    - Show "Edit Kendaraan" if edit mode
    - Show "Tambah Kendaraan" if add mode
    - _Requirements: 1.3_
  

  - [x] 4.2 Modify submit button text

    - Show "Simpan Perubahan" if edit mode
    - Show "Tambahkan Kendaraan" if add mode
    - _Requirements: 1.4_

- [x] 5. Implement photo handling for edit mode









  - [x] 5.1 Modify `_buildPhotoSection()` to display existing photo


    - Load photo from `_originalPhotoUrl` if available
    - Show placeholder if no photo
    - Use CachedNetworkImage for better performance
    - _Requirements: 7.1, 7.5_
  
  - [x] 5.2 Ensure photo selection and removal work in edit mode


    - Allow selecting new photo to replace existing
    - Allow removing photo
    - Track photo changes separately from original
    - _Requirements: 3.4, 7.2, 7.3_
  
  - [ ]* 5.3 Write property test for photo manipulation
    - **Property 4: Photo manipulation in edit mode**
    - **Validates: Requirements 3.4, 7.2**
  
  - [ ]* 5.4 Write property test for photo preservation
    - **Property 11: Photo preservation when unchanged**
    - **Validates: Requirements 7.4**

- [x] 6. Update form submission logic for dual-mode operation





  - [x] 6.1 Modify `_submitForm()` method


    - Check `_isEditMode` to determine which provider method to call
    - Call `ProfileProvider.updateVehicle()` if edit mode
    - Call `ProfileProvider.addVehicle()` if add mode
    - Pass correct parameters for each mode
    - _Requirements: 5.1, 5.5_
  
  - [x] 6.2 Update success messages based on mode

    - Show "Kendaraan berhasil diperbarui!" if edit mode
    - Show "Kendaraan berhasil ditambahkan!" if add mode
    - _Requirements: 5.3_
  
  - [x] 6.3 Update error messages based on mode

    - Show "Gagal memperbarui kendaraan" if edit mode
    - Show "Gagal menambahkan kendaraan" if add mode
    - _Requirements: 5.4_
  
  - [ ]* 6.4 Write property test for add mode compatibility
    - **Property 6: Add mode backward compatibility**
    - **Validates: Requirements 1.5**
  
  - [ ]* 6.5 Write property test for provider state update
    - **Property 7: Provider state update after successful edit**
    - **Validates: Requirements 5.2**
  
  - [ ]* 6.6 Write property test for valid data submission
    - **Property 10: Valid data submission in edit mode**
    - **Validates: Requirements 6.5**

- [x] 7. Ensure form validation works in edit mode





  - [x] 7.1 Verify validation for editable fields


    - Test merek validation
    - Test tipe validation
    - Test warna validation
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 7.2 Ensure validation prevents submission with invalid data


    - Block API call if validation fails
    - Show appropriate error messages
    - _Requirements: 6.4_
  
  - [ ]* 7.3 Write property test for editable fields
    - **Property 3: Editable fields accept changes in edit mode**
    - **Validates: Requirements 3.1, 3.2, 3.3**
  
  - [ ]* 7.4 Write property test for validation enforcement
    - **Property 9: Form validation in edit mode**
    - **Validates: Requirements 6.4**

- [x] 8. Update VehicleDetailPage to navigate to edit mode





  - [x] 8.1 Modify `_handleEdit()` method in VehicleDetailPage


    - Navigate to VehicleSelectionPage with `isEditMode: true`
    - Pass current vehicle object
    - Handle navigation result
    - Pop back to previous page if edit successful
    - _Requirements: 4.1, 4.2, 4.4_
  
  - [x] 8.2 Remove placeholder "Fitur edit akan segera tersedia" message


    - Delete the SnackBar showing placeholder message
    - _Requirements: 4.1_

- [x] 9. Test status selection in edit mode




  - [x] 9.1 Verify status radio buttons work in edit mode

    - Test switching between "Kendaraan Utama" and "Kendaraan Tamu"
    - Verify selected status is submitted correctly
    - _Requirements: 3.5_
  
  - [ ]* 9.2 Write property test for status selection
    - **Property 5: Status selection in edit mode**
    - **Validates: Requirements 3.5**

- [x] 10. Implement error handling for edit mode












  - [x] 10.1 Handle API errors gracefully


    - Display user-friendly error messages
    - Don't navigate away on error
    - Allow user to retry
    - _Requirements: 5.4_
  
  - [ ]* 10.2 Write property test for error handling
    - **Property 8: API error handling in edit mode**
    - **Validates: Requirements 5.4**

- [x] 11. Add visual distinction for read-only fields





  - [x] 11.1 Style read-only vehicle type section


    - Grey background (Colors.grey.shade100)
    - Grey border
    - Lock icon
    - _Requirements: 8.3_
  
  - [x] 11.2 Style read-only plate number field


    - Grey background when disabled
    - Lock icon suffix
    - Disabled state styling
    - _Requirements: 8.3_

- [x] 12. Write unit tests for mode detection and UI changes





  - Test isEditMode parameter sets internal state correctly
  - Test header text changes based on mode
  - Test button text changes based on mode
  - Test null/false isEditMode defaults to add mode
  - _Requirements: 1.3, 1.4, 1.5_

- [x] 13. Write widget tests for VehicleSelectionPage





  - Test widget builds correctly in add mode
  - Test widget builds correctly in edit mode
  - Test read-only fields have correct styling
  - Test editable fields remain enabled in edit mode
  - _Requirements: 2.1, 2.2, 3.1, 3.2, 3.3_

- [x] 14. Write integration tests for full edit flow





  - Test navigation from VehicleDetailPage to edit mode
  - Test data prefilling after navigation
  - Test modifying vehicle data
  - Test successful submission and navigation back
  - Test back button behavior (no save)
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 15. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
