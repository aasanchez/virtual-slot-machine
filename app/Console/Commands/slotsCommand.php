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
        $board->set_board(['J', 'J', 'J', 'Q', 'K', 'cat', 'J', 'Q', 'monkey', 'bird', 'bird', 'bird', 'J', 'Q', 'A']);
        $output->board = $board->get_board();

        $output->paylines = [['0 3 6 9 12' => 3], ['0 3 6 9 12' => 3]];
        $output->betAmount = 100;
        $output->total_win = 40;

        $this->info($output->toJson(JSON_PRETTY_PRINT));
    }
}