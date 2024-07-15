<?php
$handle = fopen(__DIR__ . '/access_data.log', 'r+');

if (flock($handle, LOCK_EX)) {
    $handle = fopen(__DIR__ . '/access_data.log', 'r+');

    // 値を取得
    $currentCount = (int) rtrim(fgets($handle));

    // ファイルポイントを先頭に置く
    rewind($handle);

    // ファイルのサイズを0に切り詰める
    ftruncate($handle, 0);

    // +1して書き込む
    fwrite($handle, $currentCount + 1);

    flock($handle, LOCK_UN);
}
