#!/bin/bash

BASEDIR="$HOME/Operaciones"
TARGET="$1"

if [[ -z "$TARGET" ]]; then
    echo "[!] Uso: $0 dominio.com"
    exit 1
fi

for cmd in subfinder assetfinder httpx-toolkit dnsx jq awk; do
    command -v $cmd >/dev/null 2>&1 || {
        echo "[-] Falta dependencia: $cmd"
        exit 1
    }
done

OP_DIR="$BASEDIR/$TARGET"
mkdir -p "$OP_DIR"

echo "[+] Target: $TARGET"
echo "[+] Output: $OP_DIR"

# 1. ENUM
subfinder -d "$TARGET" -silent > "$OP_DIR/subs_raw.txt"
assetfinder --subs-only "$TARGET" >> "$OP_DIR/subs_raw.txt"
sort -u "$OP_DIR/subs_raw.txt" > "$OP_DIR/subdominios.txt"
rm "$OP_DIR/subs_raw.txt"

# 2. DNS
dnsx -silent -a -resp -l "$OP_DIR/subdominios.txt" > "$OP_DIR/dns.txt"
cut -d' ' -f1 "$OP_DIR/dns.txt" > "$OP_DIR/resueltos.txt"

# 3. HTTP
httpx-toolkit -silent -no-color -threads 50 \
-l "$OP_DIR/resueltos.txt" \
-o "$OP_DIR/lowNoice.txt"

# 4. ANALISIS
httpx-toolkit -silent -no-color -title -web-server -cdn -threads 50 \
-l "$OP_DIR/lowNoice.txt" > "$OP_DIR/analisis.txt"

# =========================
# 5. INDEXACIÓN (CLAVE)
# =========================

# dns.json → host -> ip
awk '{
  gsub(/\[|\]/,"",$2);
  printf "%s %s\n", $1, $2
}' "$OP_DIR/dns.txt" | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s 'from_entries' > "$OP_DIR/dns.json"

# lowNoice.json → host -> url
awk '{
  url=$0
  gsub(/^https?:\/\//,"",url)
  host=url
  sub(/\/.*/,"",host)
  printf "%s %s\n", host, $0
}' "$OP_DIR/lowNoice.txt" \
| jq -R 'split(" ") | {key: .[0], value: .[1]}' \
| jq -s 'from_entries' > "$OP_DIR/lowNoice.json"

# analisis.json → host -> cdn
awk '{
  url=$1
  gsub(/^https?:\/\//,"",url)
  host=url
  sub(/\/.*/,"",host)

  cdn="none"
  if (tolower($0) ~ /cloudflare/) cdn="cloudflare"
  else if (tolower($0) ~ /akamai/) cdn="akamai"
  else if (tolower($0) ~ /fastly/) cdn="fastly"
  else if (tolower($0) ~ /incapsula/) cdn="incapsula"

  printf "%s %s\n", host, cdn
}' "$OP_DIR/analisis.txt" \
| jq -R 'split(" ") | {key: .[0], value: {cdn: .[1]}}' \
| jq -s 'from_entries' > "$OP_DIR/analisis.json"
# =========================
# 6. BUILD FINAL JSON
# =========================

OUTPUT_JSON="$OP_DIR/lowNoice.json"

jq -n \
  --arg target "$TARGET" \
  --slurpfile dns "$OP_DIR/dns.json" \
  --slurpfile lowNoice "$OP_DIR/lowNoice.json" \
  --slurpfile analisis "$OP_DIR/analisis.json" '
{
  $target:{
  subdomains: [
    ($dns[0] | keys[]) as $host |
    {
      host: $host,
      ip: $dns[0][$host],
      url: ($lowNoice[0][$host] // ""),
      alive: ($lowNoice[0][$host] != null),
      cdn: ($analisis[0][$host].cdn // "none"),
      status: (
        if ($analisis[0][$host].cdn != null and $analisis[0][$host].cdn != "none")
        then "protected"
        else "exposed"
       end
       )
      }
   }
  ]
}
' > "$OUTPUT_JSON"
echo "[DONE] JSON generado en: $OUTPUT_JSON"

echo "[+] Subdominios: $(wc -l < "$OP_DIR/subdominios.txt")"
echo "[+] Resueltos: $(wc -l < "$OP_DIR/resueltos.txt")"
echo "[+] Vivos: $(wc -l < "$OP_DIR/lowNoice.txt")"
