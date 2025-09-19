<?php
$future1 = \parallel\run(function() {
    sleep(5);
    echo "5秒後に実行されました";
});

$future2 = \parallel\run(function() {
    sleep(3);
    echo "3秒後に実行されました";
});

sleep(6);
echo "6秒後に実行されました";

$future1->value();

$future2->value();
