<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Play extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'board', 'paylines', 'bet_amount', 'total_win'
    ];
}
