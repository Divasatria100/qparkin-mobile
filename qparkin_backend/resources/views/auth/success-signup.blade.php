@extends('layouts.app')

@section('title', 'Registration Success | Qparkin')

@section('content')
<div class="login-container">
    <div class="success-card">
        <div class="success-icon-large">
            <i class="fas fa-check"></i>
        </div>
        
        <div class="success-header">
            <h2>Registration Successful!</h2>
        </div>
        
        <div class="success-message">
            <p>Your account registration has been submitted successfully. Please wait for administrator approval.</p>
        </div>
        
        <div class="success-details">
            <div class="detail-item">
                <i class="fas fa-envelope"></i>
                <div class="detail-content">
                    <span class="detail-label">Email Confirmation</span>
                    <span class="detail-text">A confirmation email has been sent to your email address</span>
                </div>
            </div>
            <div class="detail-item">
                <i class="fas fa-clock"></i>
                <div class="detail-content">
                    <span class="detail-label">Approval Process</span>
                    <span class="detail-text">Your request will be reviewed within 1-3 business days</span>
                </div>
            </div>
            <div class="detail-item">
                <i class="fas fa-bell"></i>
                <div class="detail-content">
                    <span class="detail-label">Notification</span>
                    <span class="detail-text">You will receive an email notification once approved</span>
                </div>
            </div>
        </div>
        
        <div class="success-actions">
            <a href="{{ route('signin') }}" class="login-btn">
                <i class="fas fa-sign-in-alt"></i>
                Back to Sign In
            </a>
        </div>
    </div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
@endpush
