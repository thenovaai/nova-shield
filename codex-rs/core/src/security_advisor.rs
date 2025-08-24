use regex_lite::Regex;

// Lightweight heuristics to surface friendly security guidance for risky commands.
// Returns a short, user-facing reason string when a pattern is detected.
pub(crate) fn compute_security_advice(command: &[String]) -> Option<String> {
    if command.is_empty() {
        return None;
    }

    // Join tokens for simple substring checks while retaining original argv.
    let joined = command.join(" ");
    let cmd0 = command.first().map(String::as_str).unwrap_or("");

    // 1) curl|sh or wget|sh style installers
    //    - Detect in both argv tokens and bash -lc script bodies.
    if contains_curl_or_wget_pipe_to_shell(&joined) {
        return Some("detected a curl/wget pipeline into a shell; this is dangerous because it executes remote code blindly".to_string());
    }

    // 2) Destructive rm patterns
    if cmd0 == "rm" && joined.contains("-rf") {
        return Some(
            "detected a potentially destructive rm -rf; double-check paths before continuing"
                .to_string(),
        );
    }

    // 3) World-writable perms
    if cmd0 == "chmod" && joined.contains("777") {
        return Some("detected chmod 777; avoid world-writable permissions".to_string());
    }

    // 4) Block device or raw disk writes
    if cmd0 == "dd" && (joined.contains("/dev/") || joined.contains("of=")) {
        return Some("detected dd to a device/file; verify target to avoid data loss".to_string());
    }

    // 5) Potential credential or wallet file access/exfil
    if touches_sensitive_crypto_paths(&joined) {
        return Some(
            "access to sensitive keys/wallet paths detected; ensure you trust the command"
                .to_string(),
        );
    }

    // 6) bash -lc with suspicious body (fallback for complex scripts)
    if cmd0 == "bash" && command.get(1).map(String::as_str) == Some("-lc") {
        if let Some(script) = command.get(2) {
            if contains_curl_or_wget_pipe_to_shell(script) {
                return Some(
                    "detected a curl/wget pipeline into a shell inside bash -lc".to_string(),
                );
            }
            if script.contains("rm -rf") {
                return Some("detected potentially destructive rm -rf inside bash -lc".to_string());
            }
        }
    }

    None
}

fn contains_curl_or_wget_pipe_to_shell(s: &str) -> bool {
    // e.g., curl https://... | sh, wget -qO- ... | bash
    // Keep it simple and robust without deep parsing.
    // Compile-on-call is acceptable here: this runs only on approval paths.
    let re = Regex::new(r"(?i)(curl|wget)[^\n|]*\|\s*(sh|bash)").unwrap();
    re.is_match(s)
}

fn touches_sensitive_crypto_paths(s: &str) -> bool {
    // Common sensitive directories/files for crypto users and auth material.
    const MARKERS: &[&str] = &[
        ".ssh",
        ".gnupg",
        "wallet.dat",
        "keystore",
        "metamask",
        "ledger",
        "solana",
        "ethereum",
        "secp256k1",
        "id_rsa",
        "id_ed25519",
        "api_key",
        "private_key",
        "mnemonic",
    ];
    MARKERS.iter().any(|m| s.contains(m))
}
