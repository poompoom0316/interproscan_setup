#!/bin/bash

# 使用方法の確認
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <blast_output_file> <input_fasta>  <output_fasta>"
    exit 1
fi

BLAST_OUT=$1
INPUT_FASTA=$2
OUTPUT_FASTA=$3
#
#BLAST_OUT="${cdd_out}/${idi}.txt"
#INPUT_FASTA="${protein_path}"
#OUTPUT_FASTA=${pks_res}/${idi}.fasta

# 出力ファイルの初期化
> "$OUTPUT_FASTA"

echo "Processing $BLAST_OUT ..."

# 1. FASTAファイルにインデックスを貼る (samtools faidxに必要)
if [ ! -f "${INPUT_FASTA}.fai" ]; then
    echo "Indexing $INPUT_FASTA ..."
    samtools faidx "$INPUT_FASTA"
fi

# 2. PKS_KS領域を抽出し、クエリごとに開始位置でソートして処理
# grepで"PKS_KS"を含む行を抜き出し、
# sort -k1,1 -k6,6n で「第1列(ID)で昇順」かつ「第6列(開始位置)で数値昇順」に並び替えます
grep "PKS_KS" "$BLAST_OUT" | sort -k1,1 -k6,6n | awk -F'\t' '
{
    query_id = $1;
    start_pos = $6;
    end_pos = $7;

    # クエリIDが変わったらカウントをリセット
    if (query_id != last_id) {
        ks_count = 1;
        last_id = query_id;
    } else {
        ks_count++;
    }

    # 出力形式: クエリID  開始  終了  新配列名
    print query_id, start_pos, end_pos, query_id "_KS" ks_count;
}' | while read -r QID START END NEW_NAME; do

    echo "Extracting $NEW_NAME ($QID:$START-$END) ..."

    # 3. samtools faidx で配列を抽出し、ヘッダーを書き換えて保存
    # samtoolsはデフォルトで >ID:start-end というヘッダーを出すため、sedで置換します
    samtools faidx "$INPUT_FASTA" "$QID:$START-$END" | sed "1s/.*/>$NEW_NAME/" >> "$OUTPUT_FASTA"

done

echo "------------------------------------------"
echo "完了！ 配列は $OUTPUT_FASTA に保存されました。"