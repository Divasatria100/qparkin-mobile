@extends('layouts.app')

@section('title', 'Sign Up | Qparkin')

@section('content')
<div class="login-container">
    <div class="login-card" id="signupCard">
        <div class="login-header">
            <h2>QPARKIN</h2>
            <p class="info-text">Your request will be sent to the administrator for approval</p>
        </div>

        <form id="signupForm" method="POST" action="{{ route('register') }}" enctype="multipart/form-data">
            @csrf
            <div class="form-group">
                <div class="input-wrapper">
                    <input type="text" id="name" name="name" value="{{ old('name') }}" required>
                    <label for="name">Full Name</label>
                    <span class="error-message" id="nameError">Please enter a valid name (at least 5 characters)</span>
                </div>
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <input type="email" id="email" name="email" value="{{ old('email') }}" required>
                    <label for="email">Email Address</label>
                    <span class="error-message" id="emailError">Please enter a valid email address</span>
                </div>
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <input type="text" id="mallName" name="mall_name" value="{{ old('mall_name') }}" required>
                    <label for="mallName">Nama Mall</label>
                    <span class="error-message" id="mallNameError">Please enter a valid mall name</span>
                </div>
            </div>

            <div class="form-group full-width">
                <div class="input-wrapper">
                    <input type="url" id="googleMapsUrl" name="google_maps_url" placeholder=" " value="{{ old('google_maps_url') }}" required>
                    <label for="googleMapsUrl">Link Google Maps</label>
                    <small class="input-hint">Contoh: https://maps.app.goo.gl/xxxxx atau https://www.google.com/maps/place/...</small>
                    <span class="error-message" id="googleMapsUrlError">Please enter a valid Google Maps URL</span>
                </div>
            </div>

            <div class="form-group full-width">
                <div class="input-wrapper">
                    <div class="photo-upload-container">
                        <input type="file" id="mallPhoto" name="mall_photo" class="file-input" accept="image/*" required>
                        
                        <button type="button" class="upload-btn" id="uploadBtn">
                            <i class="fas fa-plus"></i>
                            <span>Upload Foto Mall</span>
                        </button>
                        
                        <div class="preview-area hidden" id="previewArea">
                            <div class="preview-content">
                                <img id="previewImage" class="preview-image" alt="Preview">
                                <button type="button" class="remove-photo" id="removePhoto">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                            <p class="preview-text">Foto mall terpilih</p>
                        </div>
                    </div>
                    <span class="error-message" id="mallPhotoError">Please upload a photo</span>
                </div>
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <div class="password-wrapper">
                        <input type="password" id="password" name="password" required>
                        <label for="password">Password</label>
                        <button type="button" class="password-toggle" id="passwordToggle">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                    <span class="error-message" id="passwordError">Password must be at least 6 characters</span>
                </div>
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <div class="password-wrapper">
                        <input type="password" id="confirmPassword" name="password_confirmation" required>
                        <label for="confirmPassword">Confirm Password</label>
                        <button type="button" class="password-toggle" id="confirmPasswordToggle">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                    <span class="error-message" id="confirmPasswordError">Passwords do not match</span>
                </div>
            </div>

            <button type="submit" class="login-btn" id="submitBtn">
                <span class="btn-text">Submit Request</span>
                <span class="btn-loader hidden"></span>
            </button>
        </form>

        <div class="signup-link">
            <p>Already have an account? <a href="{{ route('signin') }}">Sign in</a></p>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
@endpush

@push('scripts')
<script src="{{ asset('js/signup-ajax.js') }}"></script>
@endpush
