<?php

namespace App\Console\Commands;

use App\Play;
use App\Resources\Board;
use App\Resources\PayLines;
use App\Resources\Winning;
use Illuminate\Console\Command;

class videoslotsCommand extends Command
{
    protected $signature = 'videoslots';

    protected $description = 'run videoslots test';

    public function handle()
    {
        $play = new Play();
        $board = new Board();
        $BET_AMOUNT= 100;

        //$board->set_board(['J', 'J', 'J', 'Q', 'K', 'cat', 'J', 'Q', 'monkey', 'bird', 'bird', 'bird', 'J', 'Q', 'A']);
        $play->setBoard($board->get_board());
        $pay_lines = new PayLines($board->get_board());

        $play->setPlayLines($pay_lines->getWinners());

        $play->setBetAmount($BET_AMOUNT);

        $total_win = new Winning($pay_lines->getWinners(),$BET_AMOUNT);
        $play->setTotalWin($total_win->getTotal());

        $this->info(json_encode($play,JSON_PRETTY_PRINT));
    }
}
