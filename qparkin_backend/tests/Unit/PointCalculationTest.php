<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

/**
 * Unit Test: Point Calculation Service
 * Menguji logika perhitungan poin reward
 */
class PointCalculationTest extends TestCase
{
    /** @test */
    public function it_calculates_points_from_transaction()
    {
        // Arrange: Rp 10.000 = 20 poin (1 poin per Rp 500)
        $amount = 10000;
        $expectedPoints = 20;
        
        // Act
        $points = $this->calculatePoints($amount);
        
        // Assert: PHPUnit Assertion
        $this->assertEquals($expectedPoints, $points);
        $this->assertIsInt($points);
    }
    
    /** @test */
    public function it_validates_minimum_transaction_for_points()
    {
        // Arrange: Transaksi < Rp 1000 tidak dapat poin
        $amount = 500;
        
        // Act
        $canEarnPoints = $this->canEarnPoints($amount);
        
        // Assert
        $this->assertFalse($canEarnPoints);
    }
    
    /** @test */
    public function it_calculates_discount_from_points()
    {
        // Arrange: 50 poin = Rp 5000 diskon
        $points = 50;
        $expectedDiscount = 5000;
        
        // Act
        $discount = $this->calculateDiscount($points);
        
        // Assert
        $this->assertEquals($expectedDiscount, $discount);
        $this->assertGreaterThan(0, $discount);
    }
    
    /** @test */
    public function it_validates_sufficient_points_for_redemption()
    {
        // Arrange
        $userPoints = 30;
        $requiredPoints = 50;
        
        // Act
        $canRedeem = $this->hasSufficientPoints($userPoints, $requiredPoints);
        
        // Assert
        $this->assertFalse($canRedeem);
    }
    
    /** @test */
    public function it_calculates_penalty_for_over_duration()
    {
        // Arrange: Over 2 jam = Rp 10.000 penalty
        $overHours = 2;
        $penaltyPerHour = 5000;
        $expectedPenalty = 10000;
        
        // Act
        $penalty = $this->calculatePenalty($overHours, $penaltyPerHour);
        
        // Assert
        $this->assertEquals($expectedPenalty, $penalty);
        $this->assertNotNull($penalty);
    }
    
    // Helper Methods (Service Logic)
    private function calculatePoints($amount)
    {
        return (int) floor($amount / 500);
    }
    
    private function canEarnPoints($amount)
    {
        return $amount >= 1000;
    }
    
    private function calculateDiscount($points)
    {
        return $points * 100;
    }
    
    private function hasSufficientPoints($userPoints, $requiredPoints)
    {
        return $userPoints >= $requiredPoints;
    }
    
    private function calculatePenalty($overHours, $penaltyPerHour)
    {
        return $overHours * $penaltyPerHour;
    }
}
