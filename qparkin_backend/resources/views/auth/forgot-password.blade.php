@extends('layouts.app')

@section('title', 'Forgot Password | Qparkin')

@section('content')
<div class="login-container">
    <div class="login-card" id="forgotPasswordCard">
        <div class="login-header">
            <h2>QPARKIN</h2>
            <p>Enter your email to reset your password</p>
        </div>

        <form id="forgotPasswordForm" method="POST" action="{{ route('password.email') }}">
            @csrf
            <div class="form-group">
                <div class="input-wrapper">
                    <input type="email" id="email" name="email" value="{{ old('email') }}" required>
                    <label for="email">Email Address</label>
                    <span class="error-message" id="emailError">Please enter a valid email address</span>
                </div>
            </div>

            <button type="submit" class="login-btn" id="submitBtn">
                <span class="btn-text">Send Reset Link</span>
                <span class="btn-loader"></span>
            </button>
        </form>

        <div class="signup-link">
            <p>Remember your password? <a href="{{ route('signin') }}">Sign in</a></p>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/forgot-password.js') }}"></script>
@endpush
