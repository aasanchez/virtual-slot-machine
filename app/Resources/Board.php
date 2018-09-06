<?php

namespace App\Resources;


class Board
{
    protected $board;
    protected $SYMBOLS = ['9', '10', 'J', 'Q', 'K', 'A', 'cat', 'dog', 'monkey', 'bird'];

    function __construct()
    {

        $this->board = $this->newBoard();
    }

    private function newBoard()
    {
        foreach (range(0, 14) as $number) {
            $this->board[] = $this->get_symbol();
        }
        return $this->board;
    }

    private function get_symbol()
    {
        return $this->SYMBOLS[array_rand($this->SYMBOLS)];
    }

    public function get_board()
    {
        return $this->board;
    }

    public function get_display()
    {
        $output = [
            [$this->board[0], $this->board[3], $this->board[6], $this->board[9], $this->board[12]],
            [$this->board[1], $this->board[4], $this->board[7], $this->board[10], $this->board[13]],
            [$this->board[2], $this->board[5], $this->board[8], $this->board[11], $this->board[14]],
        ];
        return $output;
    }

    public function set_board($sequence){
        $this->board = $sequence;
    }

}