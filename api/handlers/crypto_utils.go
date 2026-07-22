package handlers

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"io"
	"log"
)

// Kunci Rahasia 32 Byte untuk AES-256
var AppSecretEncryptionKey = []byte("PusdatDiskominfo2026AESKeyS3cure123")

// EncryptData mengenkripsi string menjadi Base64 cipher
func EncryptData(text string) string {
	if text == "" {
		return ""
	}

	block, err := aes.NewCipher(AppSecretEncryptionKey)
	if err != nil {
		log.Println("Crypto Error:", err)
		return text
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return text
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		return text
	}

	cipherText := gcm.Seal(nonce, nonce, []byte(text), nil)
	return base64.StdEncoding.EncodeToString(cipherText)
}

// DecryptData mendekripsi Base64 cipher menjadi string asli
func DecryptData(cryptoText string) string {
	if cryptoText == "" {
		return ""
	}

	data, err := base64.StdEncoding.DecodeString(cryptoText)
	if err != nil {
		// FALLBACK: Jika data di DB belum terenkripsi (plain text), kembalikan teks aslinya
		return cryptoText
	}

	block, err := aes.NewCipher(AppSecretEncryptionKey)
	if err != nil {
		return cryptoText
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return cryptoText
	}

	nonceSize := gcm.NonceSize()
	if len(data) < nonceSize {
		return cryptoText
	}

	nonce, cipherText := data[:nonceSize], data[nonceSize:]
	plainText, err := gcm.Open(nil, nonce, cipherText, nil)
	if err != nil {
		// FALLBACK: Jika dekripsi gagal, kembalikan teks aslinya
		return cryptoText
	}

	return string(plainText)
}

// === API GOLANG - DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===
