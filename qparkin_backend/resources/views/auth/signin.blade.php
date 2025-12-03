@extends('layouts.app')

@section('title', 'Login | Qparkin')

@section('content')
<div class="login-container">
    <div class="login-card" id="loginForm">
        <div class="login-header">
            <h2>QPARKIN</h2>
            <p>Please sign in to your account</p>
        </div>

        <form id="signinForm" method="POST" action="{{ route('signin') }}">
            @csrf
            
            @if ($errors->any())
                <div class="alert alert-error">
                    {{ $errors->first() }}
                </div>
            @endif

            <div class="form-group">
                <div class="input-wrapper">
                    <input type="text" id="username" name="name" value="{{ old('name') }}" required>
                    <label for="username">Username</label>
                    <span class="error-message" id="usernameError">Please enter a valid username</span>
                </div>
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <div class="password-wrapper">
                        <input type="password" id="password" name="password" required>
                        <label for="password">Password</label>
                        <button type="button" class="password-toggle" id="passwordToggle">
                            <span class="eye-icon"></span>
                        </button>
                    </div>
                    <span class="error-message" id="passwordError">Password must be at least 6 characters</span>
                </div>
            </div>

            <div class="form-options">
                <div class="remember-wrapper">
                    <input type="checkbox" id="remember" name="remember">
                    <label for="remember" class="checkbox-label">
                        <span class="checkmark"></span>
                        Remember me
                    </label>
                </div>
                <a href="{{ route('password.request') }}" class="forgot-password">Forgot password?</a>
            </div>

            <button type="submit" class="login-btn" id="submitBtn">
                <span class="btn-text">Sign In</span>
                <span class="btn-loader"></span>
            </button>
        </form>

        <div class="signup-link">
            <p>Don't have an account? <a href="{{ route('register') }}">Sign up</a></p>
        </div>
    </div>

    <div class="success-message" id="successMessage">
        <div class="success-icon">✓</div>
        <h3>Login Successful!</h3>
        <p>You are being redirected to your dashboard...</p>
    </div>
</div>
@endsection

@push('scripts')
<script src="{{ asset('js/signin.js') }}"></script>
@endpush
