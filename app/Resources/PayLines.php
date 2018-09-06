<?php

namespace App\Resources;


class PayLines
{
    protected $PAY_LINES= [
        [0, 3, 6, 9, 12],
        [1, 4, 7, 10, 13],
        [2, 5, 8, 11, 14],
        [0, 4, 8, 10, 12],
        [2, 4, 6, 10, 14]
    ];

    function __construct($sequence)
    {

    }

}