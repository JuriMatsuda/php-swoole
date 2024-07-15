<?php
$path = __DIR__ . '/file_version.log';

// ファイルが存在しない場合は作成
if (!is_file($path)) {
    touch($path);
}

while (true) {
    // ファイルを開く
    $handle = fopen(__DIR__ . '/access_data.log', 'r+');
    $currentVersion = file_get_contents($path);

    // 値を取得
    $currentCount = (int) rtrim(fgets($handle));

    // ファイルポイントを先頭に置く
    rewind($handle);

    // 前の値を確認する
    $checkVersion = file_get_contents($path);

    if ($checkVersion === $currentVersion) {
        // バージョンを更新
        file_put_contents($path, $currentVersion + 1);

        // ファイルのサイズを0に切り詰める
        ftruncate($handle, 0);

        // +1して書き込む
        fwrite($handle, $currentCount + 1);

        // 処理終了
        break;
    } else {
        echo "failed write. \n";

        // クローズする
        fclose($handle);

        // 一瞬待つ
        usleep(100);
    }
}
