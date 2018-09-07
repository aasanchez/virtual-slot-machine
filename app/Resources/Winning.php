<?php

namespace App\Resources;


class Winning
{
    private $WINNING_RULES = [
        3 => 0.2,
        4 => 2,
        5 => 10,
    ];

    private $bet = null;

    private $winners = [];

    private $amount = 0;

    public function __construct($winners, $bet)
    {
        $this->bet = $bet;
        $this->winners = $winners;
        $this->amount = $this->getAmount();
    }

    private function getAmount()
    {
        $amount = 0;
        foreach ($this->winners as $line) {
            $occurrence = array_values($line)[0];
            $amount = $amount + ($this->bet * $this->WINNING_RULES[$occurrence]);
        }
        return $amount;
    }

    public function getTotal()
    {
        return $this->amount;
    }
}