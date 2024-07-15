<?php
$lockFile = sys_get_temp_dir() . '/lock.file';

while (true) {
    // ファイルキャッシュ消す
    clearstatcache();

    // ファイルがロックされているか確認
    if (file_exists($lockFile)) {
        echo "The file is locked. \n";
        usleep(200);
        continue;
    }

    $isCreated = touch($lockFile);

    if ($isCreated === false) {
        echo "The file is locked. \n";
        usleep(200);
        continue;
    }

    $handle = fopen(__DIR__ . '/access_data.log', 'r+');

    // 値を取得
    $currentCount = (int) rtrim(fgets($handle));

    // ファイルポイントを先頭に置く
    rewind($handle);

    // +1して書き込む
    fwrite($handle, $currentCount + 1);

    // ロックファイルを消す
    unlink($lockFile);
    break;
}
