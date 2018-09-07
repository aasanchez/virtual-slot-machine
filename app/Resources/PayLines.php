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

    protected $payLines;

    protected $line;
    protected $sequence;

    function __construct($sequence)
    {
        $this->sequence = $sequence;
        $this->line = $this->order($this->sequence);
        //print_r($this->line);
        $this->getLines($this->PAY_LINES, $this->line);
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
        foreach ($payLines as $payLineIndex => $payLineValue) {
            echo $payLineIndex . "\n";
            foreach ($payLineValue as $lineIndex => $value) {
                echo "$lineIndex => $value ==> $line[$value]\n";

            }
            echo "\n\n";
        }
    }

    private function checkLine()
    {

    }
}