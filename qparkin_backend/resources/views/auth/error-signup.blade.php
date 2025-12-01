@extends('layouts.app')

@section('title', 'Registration Error | Qparkin')

@section('content')
<div class="login-container">
    <div class="error-card">
        <div class="error-icon-large">
            <i class="fas fa-times"></i>
        </div>
        
        <div class="login-header">
            <h2>Registration Failed</h2>
        </div>
        
        <div class="success-message">
            <p>{{ session('error') ?? 'An error occurred during registration. Please try again.' }}</p>
        </div>
        
        <div class="success-actions">
            <a href="{{ route('register') }}" class="login-btn">
                <i class="fas fa-redo"></i>
                Try Again
            </a>
            <a href="{{ route('login') }}" class="login-btn secondary">
                <i class="fas fa-sign-in-alt"></i>
                Back to Login
            </a>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
@endpush
