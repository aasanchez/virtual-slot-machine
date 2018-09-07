<?php

namespace App;


class Play
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */

    public $board;

    public $play_lines;

    public $bet_amount;

    public $total_win;

    public function setPlayLines($play_lines){
        $this->play_lines =$play_lines;
    }

    public function setBoard($board){
        $this->board = $board;
    }

    public function setBetAmount($bet_amount){
        $this->bet_amount = $bet_amount;
    }

    public function setTotalWin($total_win){
        $this->total_win = $total_win;
    }


}
