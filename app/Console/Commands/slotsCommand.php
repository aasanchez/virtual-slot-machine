<?php

namespace App\Console\Commands;

use App\Play;
use App\Resources\Board;
use App\Resources\PayLines;
use Illuminate\Console\Command;


class SlotsCommand extends Command
{
    protected $signature = "slot";

    protected $description = "run slot command";


    public function handle()
    {
        $output = new Play();
        $board = new Board;
        $board->set_board(['J', 'J', 'J', 'J', 'K', 'cat', 'J', 'Q', 'monkey', 'bird', 'bird', 'bird', 'J', 'Q', 'A']);
        //$board->set_board(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O']);
        $output->board = $board->get_board();

        $paylines = new PayLines($output->board);

        //$this->info(json_encode($paylines->getLines()));
        $output->paylines = $paylines->getWinners();
        $output->betAmount = 100;
        $output->total_win = 40;

        $this->info($output->toJson(JSON_PRETTY_PRINT));
    }
}