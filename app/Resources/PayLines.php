<?php

namespace App\Resources;


class PayLines
{
    protected $PAY_LINES = [
        [0, 3, 6, 9, 12],
        [1, 4, 7, 10, 13],
        [2, 5, 8, 11, 14],
        [0, 4, 8, 10, 12],
        [2, 4, 6, 10, 14]
    ];

    protected $GRID = [
        0, 3, 6, 9, 12, 1, 4, 7, 10, 13, 2, 5, 8, 11, 14
    ];

    private $payLines;

    private $line;
    private $sequence;
    private $winningLines;

    function __construct($sequence)
    {
        $this->sequence = $sequence;
        $this->line = $this->order($this->sequence);
        $this->payLines = $this->getLines($this->PAY_LINES, $this->line);
        $this->winningLines = $this->getWinningLines($this->payLines);
    }

    public function order($sequence)
    {
        foreach ($this->GRID as $key => $value) {
            $line[$value] = $sequence[$key];
        }
        ksort($line);
        return $line;
    }

    private function getLines($payLines, $line)
    {
        $output = [];
        foreach ($payLines as $payLineIndex => $payLineValue) {
            foreach ($payLineValue as $lineIndex => $value) {
                $output[$payLineIndex][$lineIndex] = $line[$value];
            }
        }
        return $output;
    }

    private function getWinningLines($lines)
    {
        $possibleLines = $this->getPossibleLines($lines);
        $winners = $this->checkWinning($possibleLines);
        print_r($winners);
        return $winners;
    }

    private function getPossibleLines($lines)
    {
        $possibleLines = array_map(function ($line) {
            if (max(array_count_values($line)) < 3) {
                $line = null;
            };
            return $line;
        }, $lines);
        return array_values(array_filter($possibleLines));
    }

    private function checkWinning($lines){
        $winners = array_map(function ($line) {
            $symbol = array_keys(array_count_values($line))[0];
            $previous = null;
            $count = 0;
            foreach ($line as $value){
                if($count == 0){
                    $previous = $value;
                    $count++;
                }
            }
        }, $lines);
    }
}