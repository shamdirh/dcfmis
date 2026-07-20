-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 20, 2026 at 10:15 AM
-- Server version: 8.0.45
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pusdat_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `ip_blocks`
--

CREATE TABLE `ip_blocks` (
  `id` int NOT NULL,
  `nama_blok` varchar(100) DEFAULT NULL,
  `jenis_ip` enum('Publik','Lokal') DEFAULT 'Publik',
  `cidr_block` varchar(255) DEFAULT NULL,
  `keterangan` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ip_blocks`
--

INSERT INTO `ip_blocks` (`id`, `nama_blok`, `jenis_ip`, `cidr_block`, `keterangan`) VALUES
(1, 'Blok IP Pusat Data Balaikota', 'Publik', 'g/HC9QMZxL02d0VOxbmUcUUuwF3o+qgEoyD+KFhyBBsp+ZXwbTt4g0Tj7Q==', 'IP Publik Kota Bogor'),
(2, 'IP Publik Pusat Data ISP Asnet', 'Publik', 'nRwidVe522xQvOngcVS3aJef0lEMo9JQlRMxbKbUuFg+QGNWhUbyg3owx5w=', 'IP Publik Server Cliset 1 dan 2 di Asnet'),
(3, 'IP Lokal Pusat Data Balaikota', 'Lokal', 'F8jhv1Hn3BZ9TZPiPDVbYRdGD/C+YyIX40nSUlAFIumcB8sEzzIVL+s=', 'Ip Lokal Server Proxmox'),
(4, 'IP Lokal Pusat Data ISP Asnet', 'Lokal', 't7f7n8AqFXvHeM6hkvZxY2+BPD+IDA1Jqe/goz9NoUOfN6C0DEZ/bDQnmw==', 'IP Lokal Server-Server di Pusat Data Asnet');

-- --------------------------------------------------------

--
-- Table structure for table `ip_usages`
--

CREATE TABLE `ip_usages` (
  `id` int NOT NULL,
  `ip_block_id` int NOT NULL,
  `server_id` int DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `kegunaan` varchar(255) DEFAULT NULL,
  `port_info` text,
  `status` varchar(50) DEFAULT 'Aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ip_usages`
--

INSERT INTO `ip_usages` (`id`, `ip_block_id`, `server_id`, `ip_address`, `kegunaan`, `port_info`, `status`) VALUES
(20, 3, 2, 'BgnKJ3IwBSpXS/B1ZQYRQ218e6zbqOgC6Jo476wwwgVdtK5DEMM=', 'Akses SSH Server Proxmox 2 Balaikota', 'rbMl2r40Pu8LHtLVC83erQ5oJrw4I7yvzU2k2c1DmFFhwNXXGA5kklAQsGM=', 'Aktif'),
(21, 3, 1, 'CFA1ZOUQ7jlytCuwARzrDfis1gsEK6ojJ52J/rwvjR0uSZgkrF8=', 'Akses SSH Server Proxmox Balaikota 1', 'SKOE4k5Rj9lUVMMvwhRpEvx8an80Om628S1dZnjqhP9KjRn4FZXXq9jdkjM=', 'Aktif'),
(24, 4, 4, '8zktntNTRAF+S+ljl2MvKUZaN918k94fv6yWaaLwfkq5j92MDmUJHvo=', 'Akses SSH dan Web Server Proxmox 1 Asnet', 'Dh6Y8Ns2BO6E4hT5Aa+eFhMQQJasLWxoq4CduvGs64ELaJmJ6YZ84V3TbNo=', 'Aktif'),
(25, 4, 3, 'fOSjar4dSc5rQjc9X/hnRss4t8EdtlyzG0gzSVw3XJ361VSFfjKVbw==', 'Akses SSH dan Web Server VMware 1 Asnet', 'uskYJD/w78Yu2F9eOSi04HwnWBMi5WM3pdF9qPugfO9tUbDvS/uHCFZ+', 'Aktif'),
(27, 4, 5, 'Iz4JCh834FpEh0cWASN3xT2QaAE6tP4kxRhYh8NGOOuOTJ16RCZr4sc=', 'Akses SSH  Server E-Office BKAD', 'a+gxsluXJ7jhbSD6jJMzXLsYLDHJrDoef3uHaNvgBxZaSg==', 'Aktif'),
(28, 4, 6, 'RVLGVfrmclATP5KJcBCrShRqeywsqZ2MlQtYNFI7C3UZnY3q63Ia08A=', 'Akses SSH Server SIMAE Dishub', 'WWkXv6EvCXjHNilOwu3Lbx0D1optaMmbDQARXjU3KiM18w==', 'Aktif'),
(31, 3, 7, 'UNWsxSq6YiJ3ygUuLuqv//CtAVFe+HD9aQih8zW4I7d6tIqHuBKK', 'Akses SSH Server Labs CCTV Analytict', 'T/rwpL3KmGKsvti0MDizXJBQOiMhuAGDDJq2lo0UJAauow==', 'Aktif'),
(38, 3, 8, 'v4x3YQN14kcynUcHb/y67qXccUuGtmvhqIl4D1wmUzWEymbnxFlx', 'Akses SSH Server Labs DGFMIS Balaikota', 'D6hCwRMPlGOiZNJ+tr+HCepAqbZe75yFxm4khYi/wo4rjg==', 'Aktif'),
(39, 1, 8, 'W1DllRBodp2RlFyLZ0SrY+H4c0zYSksjbO0sEdEopJuRaPsrkOfxu6g=', 'Akses Web  Server Labs DGFMIS Balaikota', '6D5XzsNIQG7nBBwtXuij5T0+Dt/Fz4unreNzd5KLSJiMZw7mHNDn76e7lw==', 'Aktif');

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `id` int NOT NULL,
  `nama_lengkap` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `aktivitas` text NOT NULL,
  `waktu` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `logs`
--

INSERT INTO `logs` (`id`, `nama_lengkap`, `email`, `aktivitas`, `waktu`) VALUES
(1, '6kA0LSswxvmN+G8umMryPFznXyfe2th+WLgzi4wFgbQ66t/vm7GDioFYu7kB1A==', 'UD/w4Ugj1loiU60Tfn2Z5GPN/RSvjvVGufPm5wkPpO4tt2VZ/MFnnrPgevcx7ghWSw==', 'menambahkan user sistem baru: Saeful Hamdi, A.Md', '2026-07-16 15:16:56'),
(2, 'BvgwG2a6GOwtTUKldWgbWs8MF1gU0+7NyjRSw2ayLZQWLez1UahLSJjTv0ikhg==', 'R6jq0GfOc6a8elgTEJqnzwPDaPx+uCQdifPcBcsu6UhCTL995E4Rn64kgIXOQXd7ig==', 'menambahkan user sistem baru: Saiful Hilal, A.Md.Kom', '2026-07-16 15:18:25'),
(3, '/Jb/hBIm+M3cjCw+HwHVJm9Q+RyjM/34PPYBkDwdD/GxJm2it6qicyGQHINPrQ==', 'NKGJUZ+BTB7ZBUsTKL0Znbaty+VaDiqkbpE5QK9+xBPSaDkEIXr1oM7/QrOoyvqp7g==', 'menambahkan user sistem baru: Netty Herawati, S.Kom.', '2026-07-16 15:19:23'),
(4, 'ZhSXcD91WgmujLCKDRT69F1fFGUDX/pXT8pd/bL7EtmfgviImK78B5igSALjtpEANA4=', 'uERCtAkHDjE7QxSON/Mgz/m60HHFg0McBDYRRxrAzc9WnTSwCizSU5gO1/jldaRAvKZbJBo=', 'Berhasil login', '2026-07-16 15:19:53'),
(5, 'kAgi1TFfllPkM2gNvj+qAzi6JdteSIVsIOHK1y978AneIBVWlwM1kWZTPZHfEw==', 'kFIve1SfTllARieFGa3eidNpMPm9JNVfrfZemkYNksAMhCe/hQbnmEfusJaed0jVFQ==', 'Berhasil login', '2026-07-16 15:21:01'),
(6, 'CvlQrPHnTlmfLU8cms5Odn3P09LXGUWN5/i3ZflqlLedRuhoqDIr8uG5Pl+zkg==', 'ATcFQHX9or2+iEFq3Z8WxvQTJ9WD442b27Yf5qEai2KpbomDYotvdmKISugQzco=', 'Berhasil login', '2026-07-16 15:23:12'),
(7, 'PydB1eA0QxIOjMSdWE1pd2esDfhP0QS4vLUop/rOUYsBKmT4Od6LnljnRXm0T0Ol9gc=', 'VFznVlmpBMhAJiBktu6MYdJDu9XgJqg5DkDC6rZIaK6eFcEZXt9re2M0SqAdv4/AfVHMaRzd6Q==', 'Berhasil login', '2026-07-16 15:24:12'),
(8, 'nYvS0PCIPIsMkVKr6LzrZZv1l4sgOLPLHfzoRXSb9AiwmRf9kfWMVNBo/ybZxkMESD0=', 'y2d4qsH+g665Vi4vN5xiyfxG7roR5fssXJva9akNNxy4S3eixFct+p6qhzPaqhBXgW8O9AtLGw==', 'menambahkan laporan piket harian baru', '2026-07-16 15:30:39'),
(9, 'xoOtgLI5P4k7Hnd1M9uEIIjFmyPNH3bZfSHHLaJolWAisR8qObvhT/ZUk9k2zWzSTRQ=', 'aeakpsYlKy67RTavOoCSyug7vRVHHmElrr173EQA1KpLH3baZB69/FT+yMcc1iWHSVE+huhdvQ==', 'mengedit blok IP (Blok IP Pusat Data Balaikota)', '2026-07-16 16:09:06'),
(10, 'AR9JeF0pnEkMas6TnToPSSEQ9BmDy/1Qrn7+CACDQg7xZambIQqbZJP97aChgX6wSH8=', 'F7MZ4FtwRHwq3UTwYQjyhU5iRRTzIS0GXhaRMPix3LGWG29Sw8l7eYY6phj6YRHwoU3nf9gNpA==', 'menambahkan blok IP baru (IP Publik Pusat Data ISP Asnet)', '2026-07-16 16:13:57'),
(11, 'dAZTsbwZYJ5CCddSh7yf6+HBUPNGjWn/fBqYHOmwvjEa3rc4uj6NhsV+QkTHk+1ZZUc=', 'rBRSlrPOSgo2MTVHR37uHYg8IA6hfTU2e5lJnEuoa8O8ong3xowKenPZKnHdkYOm9WGBFC8B+w==', 'menambahkan blok IP baru (IP Lokal Pusat Data Balaikota)', '2026-07-16 16:15:02'),
(12, 'TB5D+UNPRTXPPsjMoOf0yKeM3cyGbmOjMoC2EKkKZs7lo+2Bz3RnO1O9xauxnuwRkg4=', 'KArhPp9qmSdzwYeBfeeS+rIBUPK21EzjkGv5cwll4ASlOHfCWk1+WyS1xmH7k4qcOfC3gHaYkA==', 'menambahkan blok IP baru (IP Lokal Pusat Data ISP Asnet)', '2026-07-16 16:16:44'),
(13, 'WFjThJb32sYpxiWNADf81cS7eQahntWO/w2nRD+/b5SrxKYZnv82r1GpyVMZ7+GqXFU=', 'BWsQPPkxIdFwUODAmLSd6PpYvMIgu3pjOdmK842La62vAc7hfGFXLBRjh0SQS7JJmUqUJ1kewQ==', 'menambahkan data server Server Proxmox Balaikota 1', '2026-07-16 16:22:19'),
(14, 'UDa2FtrvOWXOxV1Vtrlt75CVpEb4HYFe9PKuFjqIVIJNQXfyqnU1UerYvEg7k7zZL44=', 'A5gAcMT9NhZ6fa3N8Tsc6HCBdkx9Mr9T90Rl6BPLxISgNDizd07A1T19hO1k48Vz6ttEMqHjiQ==', 'mengedit data server Server Proxmox 1 Balaikota', '2026-07-16 16:35:17'),
(15, 'UOutATRH0hS1I/MNwGYyFCXUGKhWVgKo3eZTAsIlqyMJ9e919yeWaoG6BYL2dt0bQM4=', 'FDXYhQUfDpRXfcHxJzh6Vmk33+XdHO4UAXCr9/yYRO2c8FuJfVPgI3s1UeT3xXIUXbfHZeWU8w==', 'menambahkan data server Server Proxmox 2 Balaikota', '2026-07-16 16:38:23'),
(16, 'WueUZBOWTFHOHqdWGXZVWDMMQbxu/fYdm9tXyBXRuwRxLrbOh7uJKL6UzpqV3M5W2KM=', '2f2oNZ3AVrL2XmUivwwBcN3dtl399+2VlR6Qs4FeWokU7sFh4rNDS1I8vZMJsiPyTZKYFl7vlg==', 'mengedit data server Server Proxmox 1 Balaikota', '2026-07-16 16:39:01'),
(17, 'Ve25XYhQAqt7TDujb9GLMHW7plvKiT8q0MrlO4dzbEXz4XL2lhKzGEc6qeJlhpnrwH4=', 'VH+kKP9P6aRIg+LGnctD3xFufsKFzCmPakE1FygwU7iiDlbKE8aVGNZBJ69m/gdMECzix3/24Q==', 'menambahkan data server Server VMware 1 Asnet', '2026-07-16 16:46:20'),
(18, 'GOQAsOPnRmCtZNPOXn/YJirLEvvW5pz3l6BiAw8RO9r8vc0IM0YnV2VRTKXZGqx9ICs=', 'TpacAaXtAi2H19PsD/MCpAVW5M7DPO/5TIgxXyjqfRwp5u1ULC4HkycUTSnQynG3mbBomnZRtg==', 'menambahkan data server Server Proxmox 1 Asnet', '2026-07-16 16:50:31'),
(19, 'D6xD0pkFfRCZzBJItLqAPEmckOwTBu1TMBXmIRNjiyS8dsqeFTawgiaNKTNQCvxGAsY=', 'sqpeUtdVRBrE5ZrM8UQDOWJamZ7m0IvLCyxJvCCXB62usfo6HPLCFF6IytUH5FPotD7ZSL6GDg==', 'mengedit data server Server Proxmox 1 Asnet', '2026-07-16 16:50:58'),
(20, 'SynAJfVnG8Ks+m9lvoTHRdXqRiWeTCdzKPVHHUyeDEycEdncqutJo8B92uG1O6Rs0II=', 'oX64fAuu/UDOhIUDbAYuavIicLtc4bZ0S3n5EHMMI7ItEgeEYOb1gZ0PNTpmEjjPe6D1qlBxrQ==', 'mengedit data server Server VMware 1 Asnet', '2026-07-16 16:51:15'),
(21, 'wmalIfnZ3SnI9JESWcLYQymNHB3Ax0BA3ek3+gqVuo8Pu+5x05MEY3c9w/gcdYHCtMc=', 'MeBx9eaTcEi9N/OlVCXqrjFAS1tS4zoQw820qFLzVht56SICICDiPFgl0YehHS8VzGj6USjOOw==', 'menambahkan data server Server E-Office BKAD', '2026-07-16 20:57:00'),
(22, 'nATx0doy6XZsbMcQcYxOiuak08t8leVt5H8wFJbN8vBonnjaZ/Mjcvtwewvd34Tu2sQ=', '2F+d4TX7+WArLMb799oS0np9wVswNedWwCheSosYEm5Tc1rs0hCS4DkAhRZcG8Wn/SCR5EcOIA==', 'mengedit data server Server E-Office BKAD', '2026-07-16 20:58:13'),
(23, 'o34x2VTyT6jommo3y9LnMPKPJCSfDw6EltARiJjtdvnG2MikP9aQuPi/pjhQK44qs9w=', 'KvQfW/YofpJ+LTiKruH/B+cbZGfnc7zDX2D1sXAHUP7FAQCSr+Wkubj//GONdPLAVanf6WpwtA==', 'menambahkan data server Server SIMAE Dishub', '2026-07-16 21:02:30'),
(24, '5TIqA8HohqZ8utSjfuk4+39dBXcqgutnw2X2Xs78pFtOavUWFIMuG7wgzCr26K1Aqn4=', 'zhaUjesW6Di0fgUx5xfwK6lgajo/+WCIC8eg2c7g2ALEF/5MnU08S/SxT13pBjyF+GwmfcBCbw==', 'menambahkan data server Server Labs CCTV Analytict', '2026-07-16 21:11:06'),
(25, 'TkTJudJoXELv9/uojySFe/6CPM7P4xMx8LD3GjuxvOC5rbEutls+gVmRSLdoD9+BKh4=', '29YBiJr8dX/M4ib955LF3ONmVcSujgiqL1baZ0MZjXKv9hwtf661AHG4Gjp8Q/ZIgQVy2IOSwA==', 'menambahkan data server Server Labs DGFMIS Balaikota', '2026-07-16 21:14:43'),
(26, 'XHU5t8rmGja/HyLhwHqq9pG2Q0XvpkP9yFGyORgvzbJThWrdPzZqUnz1OUXEAXzhV8k=', 'f9mzUTUTYPAOpVxTcBjUX965fKB8XjJVlYz/4IFWNI6ARh0Sm2BhcTuASMTB1gzI4zc3tuolrg==', 'mengedit data server Server Labs CCTV Analytict', '2026-07-16 21:16:35'),
(27, '1t5SHh27YaxlwL4OVcm5IlT4JdM5YqZyTYFYVgF6o4sOxyDxg74YUNnICpTW4KHQ+XI=', 'dMETF/pgZWv7Wl6s/CTAfYIhV5xP5lzaHqv2dgotBJlEJWEpn1z5foGnxUymYqpAczpn/YXQQQ==', 'mengedit data server Server Labs DGFMIS Balaikota', '2026-07-16 21:21:26'),
(28, '2j7v8odOswoOzCgBEMkFcwae4Puce3Z731UUtJXhMyH037/SK33SfLM4YqkyFipizDs=', '1TtUPzPiTtcIswCz7ok9YZdhoXcqIbEBPuyQRUDTCLMC2hZAj5x6U6ZQ2sUTmI8PVsEiFOHE5w==', 'mengedit data server Server Labs DGFMIS Balaikota', '2026-07-16 21:24:14'),
(29, 'S6CiRHT/aMNnsXfNfvMUu9XquN2bHOj4wF2j2l1/8zA8Lw+/SvfpKlzii0zUs47c9SY=', 'ZM9Mi1gIb5BATJrCe39jOrVV8s4X2g9WqLIBLorxJ8wAhpoU84tfPjlIP4zlp4dvTXhdDpwBPQ==', 'mengedit data server Server Labs DGFMIS Balaikota', '2026-07-16 21:24:53'),
(30, 'ikaKUvIaHSOGq4uIWq5l71EdJDx2lxfmPllNpMsUpkazgYwHbUF4DjD4bavrs58uE2k=', '9tk7BBVk+UC8O/Aafn7gvR+rlzUK87zHCPXzC19R9Qreagow9ZxKNCIRZeYALt2ePaeuAq22lg==', 'mengedit data server Server Labs DGFMIS Balaikota', '2026-07-16 21:25:35'),
(31, '+lqgFUPG6uMyPmqFoLJBvmYtM0T/jzB3xPZSadu2tTpSIrY0npBeag==', 'YXAAqQ085u4bDymD7OVNOimYMCa/DIq05RCKrHYg+ZZcYLwehjK3NXfcPg+oF12W6PjmdJq7RQ==', 'Gagal login (Email tidak ditemukan)', '2026-07-16 21:28:17'),
(32, 'dvGr2aY2zKfDRwfQcsIYCBE4Zf+9XlewXsK+nEBA1L+Bah1I9i4kpsywomNvhw==', 'OE48sTZkMZT+wha61WxgvdsW7TdFyDI+btVc76M0nX5dOQUK1JqfaIRBpwrMINDAnA==', 'Berhasil login', '2026-07-16 21:28:38'),
(33, 'XY8sMwhOvt5LSoIp+lK+ugWD8lOIUmInYy9qHq2Cf7SDYUCfz8nYMukd+3piGg==', '7BqnstHk5rP0Qjv6kKLPwyEfpwmpA7Mw6zyA2rhSeUkQfdWIwPSyZOffFC8Pp7Gbew==', 'mengedit data user: Saeful Hamdi, A.Md', '2026-07-16 21:29:24');

-- --------------------------------------------------------

--
-- Table structure for table `modules`
--

CREATE TABLE `modules` (
  `id` int NOT NULL,
  `nama_modul` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `modules`
--

INSERT INTO `modules` (`id`, `nama_modul`) VALUES
(1, 'Data Spek Server'),
(2, 'Data IP Publik'),
(3, 'Data Server & Aplikasi'),
(4, 'Form Piket'),
(5, 'CCTV'),
(6, 'Manajemen Akses');

-- --------------------------------------------------------

--
-- Table structure for table `piket_fasilitas`
--

CREATE TABLE `piket_fasilitas` (
  `id` int NOT NULL,
  `piket_id` int DEFAULT NULL,
  `ac_cctv_data` json DEFAULT NULL,
  `rak_server_data` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `piket_fasilitas`
--

INSERT INTO `piket_fasilitas` (`id`, `piket_id`, `ac_cctv_data`, `rak_server_data`) VALUES
(1, 1, '{\"ac\": {\"Status AC 1 - Ruang NOC\": \"Menyala Normal\", \"Status AC 2 - Ruang Server\": \"Menyala Normal\", \"Status AC 3 - Ruang Server\": \"Menyala Normal\", \"Status AC 4 - Ruang Server\": \"Menyala Normal\", \"Status AC 5 - Ruang Server\": \"Menyala Normal\", \"Status AC 6 - Ruang Server\": \"Menyala Normal\", \"Status AC 7 - Ruang Pusat Data 2\": \"Menyala Normal\"}, \"cctv\": {\"Status CCTV 1 - Ruang NOC\": \"Menyala Normal\", \"Status CCTV 2 - Ruang Server\": \"Menyala Normal\", \"Status CCTV 3 - Ruang Server\": \"Menyala Normal\", \"Status CCTV 4 - Ruang Pusat Data 2\": \"Menyala Normal\"}}', '{\"Rak Server 1\": \"Tidak Ada Perubahan\", \"Rak Server 2\": \"Tidak Ada Perubahan\", \"Rak Server 3\": \"Tidak Ada Perubahan\", \"Rak Server 4\": \"Tidak Ada Perubahan\", \"Rak Server 5\": \"Tidak Ada Perubahan\", \"Rak Server 6\": \"Tidak Ada Perubahan\", \"Rak Server 7\": \"Tidak Ada Perubahan\", \"Rak Server 8\": \"Tidak Ada Perubahan\", \"Rak Server 9\": \"Tidak Ada Perubahan\"}');

-- --------------------------------------------------------

--
-- Table structure for table `piket_laporan`
--

CREATE TABLE `piket_laporan` (
  `id` int NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `nama_lengkap` varchar(255) DEFAULT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `tanggal_pemeriksaan` date DEFAULT NULL,
  `jam_pemeriksaan` time DEFAULT NULL,
  `kebersihan_ruangan` varchar(50) DEFAULT NULL,
  `kebersihan_sampah` varchar(50) DEFAULT NULL,
  `suhu_ruangan_server` varchar(50) DEFAULT NULL,
  `status_pc_noc` varchar(255) DEFAULT NULL,
  `catatan_kejadian` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `piket_laporan`
--

INSERT INTO `piket_laporan` (`id`, `email`, `nama_lengkap`, `jabatan`, `tanggal_pemeriksaan`, `jam_pemeriksaan`, `kebersihan_ruangan`, `kebersihan_sampah`, `suhu_ruangan_server`, `status_pc_noc`, `catatan_kejadian`, `created_at`) VALUES
(1, 'qsnX7v9G+OQ1PQfhpZiCDOqqXGJdZebS9L/q5dv1+2M2mNZ0Gx7e66TTwLpOy9jT66pvfeHK8w==', 'CvOA7v87ZqTK6nV3GD5g0pjKLj2cn4JF6WTi+pHvJh7j4vC0MAi+T97ytTPAIVHfHtw=', 'Pranta Komputer Terampil', '2026-07-16', '08:00:00', 'Bersih', 'Bersih', '20 IN 21 OUT', 'Menyala Normal', 'Pa Naufal Bapperida Memeriksa Server Simtaru jam 10,25. ', '2026-07-16 08:30:39');

-- --------------------------------------------------------

--
-- Table structure for table `piket_panel_listrik`
--

CREATE TABLE `piket_panel_listrik` (
  `id` int NOT NULL,
  `piket_id` int DEFAULT NULL,
  `nama_panel` varchar(50) DEFAULT NULL,
  `kondisi` varchar(50) DEFAULT NULL,
  `amp_r` varchar(20) DEFAULT NULL,
  `amp_s` varchar(20) DEFAULT NULL,
  `amp_t` varchar(20) DEFAULT NULL,
  `volt_r` varchar(20) DEFAULT NULL,
  `volt_s` varchar(20) DEFAULT NULL,
  `volt_t` varchar(20) DEFAULT NULL,
  `hz` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `piket_panel_listrik`
--

INSERT INTO `piket_panel_listrik` (`id`, `piket_id`, `nama_panel`, `kondisi`, `amp_r`, `amp_s`, `amp_t`, `volt_r`, `volt_s`, `volt_t`, `hz`) VALUES
(1, 1, 'Panel SDP 1', 'Bersih', '006', '006', '006', '219', '219', '220', '50'),
(2, 1, 'Panel SDP 2', 'Bersih', '006', '006', '006', '220', '220', '220', 's0'),
(3, 1, 'Panel Distribusi 1', 'Bersih', '006', '006', '006', '220', '220', '220', '50'),
(4, 1, 'Panel Distribusi 2', 'Bersih', '006', '006', '006', '220', '220', '220', '50'),
(5, 1, 'Panel Distribusi 3', 'Bersih', '006', '006', '006', '220', '220', '220', 'NA');

-- --------------------------------------------------------

--
-- Table structure for table `piket_ups`
--

CREATE TABLE `piket_ups` (
  `id` int NOT NULL,
  `piket_id` int DEFAULT NULL,
  `nama_ups` varchar(50) DEFAULT NULL,
  `kondisi_fisik` varchar(50) DEFAULT NULL,
  `temp_in` varchar(20) DEFAULT NULL,
  `temp_out` varchar(20) DEFAULT NULL,
  `led_indicator` varchar(100) DEFAULT NULL,
  `indikator_baterai` varchar(50) DEFAULT NULL,
  `in_a` varchar(50) DEFAULT NULL,
  `in_b` varchar(50) DEFAULT NULL,
  `in_c` varchar(50) DEFAULT NULL,
  `out_a` varchar(50) DEFAULT NULL,
  `out_b` varchar(50) DEFAULT NULL,
  `out_c` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `piket_ups`
--

INSERT INTO `piket_ups` (`id`, `piket_id`, `nama_ups`, `kondisi_fisik`, `temp_in`, `temp_out`, `led_indicator`, `indikator_baterai`, `in_a`, `in_b`, `in_c`, `out_a`, `out_b`, `out_c`) VALUES
(1, 1, 'UPS 1', 'Bersih', '29', '21', 'Online/Inverter LED', '5 Kotak= 100%', '220', '220', '220', '220', '220', '220'),
(2, 1, 'UPS 2', 'Bersih', '28', '21', 'Online/Inverter LED', '5 Kotak= 100%', '220', '220', '220', '220', '220', '220'),
(3, 1, 'UPS 3', 'Bersih', '29', '21', 'Online/Inverter LED', '5 Kotak= 100%', '220', '220', '220', '220', '220', '220');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `nama_role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `nama_role`) VALUES
(1, 'Super Admin'),
(2, 'Admin'),
(3, 'Eksekutif');

-- --------------------------------------------------------

--
-- Table structure for table `servers`
--

CREATE TABLE `servers` (
  `id` int NOT NULL,
  `kategori_server` enum('Virtual','Fisik') DEFAULT 'Virtual',
  `nama_server` varchar(255) DEFAULT NULL,
  `pusat_data` varchar(255) DEFAULT NULL,
  `tanggal_pembuatan` date DEFAULT NULL,
  `pembuat` varchar(100) DEFAULT NULL,
  `spek_cpu` varchar(100) DEFAULT NULL,
  `spek_ram` varchar(100) DEFAULT NULL,
  `spek_hdd` varchar(100) DEFAULT NULL,
  `software_terpasang` text,
  `kredensial_akun` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `servers`
--

INSERT INTO `servers` (`id`, `kategori_server`, `nama_server`, `pusat_data`, `tanggal_pembuatan`, `pembuat`, `spek_cpu`, `spek_ram`, `spek_hdd`, `software_terpasang`, `kredensial_akun`, `created_at`) VALUES
(1, 'Fisik', 'qdIe5qromOpj39UixkAmY5tI8I/AT0QEZYIswK/YYIatr2RKPzF9TGKkOhO5mR/o4RWscpSR', 'WHq7Rt4p6jL9bXFi8B1dR6yEfxakmOxr0pH9I9tKg7DxAb4I4Je0vXW8uBxvah6U', '2025-12-15', 'Saiful Hilal, A.Md.Kom', '32', '256', '8600', 'Sk5T2j/7CzMTJgSPByJsYHEzJXyqZrkE3D4Cyij+bQLjTn7h9k6LW/tJkxk0bX3dXzeo2fD8q9U=', 'S1lH6Ox1mHjVlwipf5vVm/z8aDymVyc9ZbVfVp1QIyzWqkl0HxjnD0GgZu6VHqtssfQMYAA4j4LtzAu5LZVG8GIIjquq5jpCOc1WXETaMF1t95ohjpaJzPVI1iorUV4OGcRd0Ss7Vjc=', '2026-07-16 09:22:19'),
(2, 'Fisik', 'p8xfgZf1DdPEKmn8Un58qPvkoTTcL8D17s+RIDmym4BCuGL34BXvATzAIZ+rG65jt0Q2fRcl', 'hDc21ojLHbnZmTxBTlDyIFEX8zOlkZC/xaRYT+SCiJQYKcu3rYAzuSm+kpA84iwf', '2025-12-25', 'Saiful Hilal, A.Md.Kom', '64', '128', '8600', 'iYSjhmdCeXmCSz4bTvT0t5lCxfoenigiRYyUZEfIYZamIpd4Ed/aRxPETnRlmJRs/sXZdHTESsS1', 'DtEt5QuD9E2VmTLMtYk9TDYjnxNWzlhA7DKKceqdZwH56gvWyjLrPqJlIInbF8S0anX6IaiSAX0VkliTGzuQZtmjxfEVUggAUY4INaZ5clJMdhisEQPyUrKJAeAjzCnEChk1lZUldgk5NQM=', '2026-07-16 09:38:23'),
(3, 'Fisik', 'QITVZ+yGUl02O7Ojc2tOVnnfaAPnDTUu5Yw5ahiqeSi46LadxhOUqudmuSqw4wh9kA==', 'EjPFga1gTLgBChqkyRy98cT1xjqwr4oc3e2P4usRuUywJA49MiDkTkh6SaA=', '2025-07-24', 'Saiful Hilal, A.Md.Kom', '32', '128', '4000', 'fTkcaBTAFOtOZd7qdUlSXsmIPsIxiEmxHJKwQChZkoz2BdciTQ19rqHN', 'u9yNu/FlI9EjeX2j1U80GkntJZbcDIszYhI8F1oAAxm2fZ4LNF5GFeYMqe9UFWtHR0DkLSTvR9L7pEeNfSxhiKgathWC4uYio7U7C9G9X92/OQqGCzFeHBsyHBGM83mG93227WNtK9wp', '2026-07-16 09:46:20'),
(4, 'Fisik', 's8RCG3Y53zuGpQTbH72Gs/BBFKuiU3bb6kXm/rse1e7ZCUXFNErkoA4kU+ju7H6IaDQ=', 'I052BNH5k6SbDJYgi8RbNVItRh4R2E17zXalHuJ1QwyRVZypQIuCbpy1qII=', '2025-12-25', 'Saiful Hilal, A.Md.Kom', '62', '128', '8600', 'IbvKGuTrwqaTaM7S7+GPV1u0PdDmhd/w1TqdD/8qpB5/7tYTPMnh60dirnQrpXE6QgU0aeP8BfA=', 'DgGmtymeydyI5ntgc3pCWdv/y43ojlnqZRk3Sk+MqXJZME2d2egoGc7OgwPhyPpSuM4BYZYZg1G0uDJlTn/lA1O4GfkoY93V3Ur3o6Rz+X4PzI9OtqDQyYQT9Q0pDuxk3wx9r/5cRg==', '2026-07-16 09:50:31'),
(5, 'Virtual', '/RXTZ7RvbQUDZegIkRSpAAdHxEA9C/MYuLQD7oHcYN6jwXCaczenSImVMBF3Jjpg', 'nfZW4ucNiyQjayIMcNGHCJdq60zY7tgBElN8+vIDJ7ynFHLklNUyecPwDMM=', '2025-07-16', 'Saiful Hilal, A.Md.Kom', '4', '8', '', 'NPgs9sCt+23QqT4M33MW3KxXJxuShL5t03PV6xbtBQFJ3BgpwUYy+WlrS8V+z0Rty2ogGxQ3', '4WquMofO8O/fBj5p9SeIJo786/MOV8EpitoeA+sqRihN4VXSvoWI64MTwkfLygPOmFmV8O+yPpchYqhoz7uc6xtYdPNhwLIK/rxg0QVq4AU/L5ylaMPlKVl+fh+B/XYFr7RpW6RF', '2026-07-16 13:57:00'),
(6, 'Virtual', 'zBoKJpi9WEptbKcif2g3D4e+1KVMAarbH/ru8LHQjRCEuuqdfe9Qx6MgM2pn224=', 'sKJ8AhYkXpXrbrPerfU0TnueuB8SFNT3noK1PbXKfY+xB8tOqVeUdD5g8Go=', '2025-05-16', 'Saiful Hilal, A.Md.Kom', '4', '8', '150', 'T+Ixg3IWfh8ZT26NKB/V5Z2uD6yJYWPiqeg29lTyS9ozvj4motqqAWBu+0YWPIFg0WrrTNDt', 'p5KTAoS/P7W8u5xuAHpau5ejdln19U2D3MN6UnTdvg81uLo6XtG9jBRBa4rbM0GlXtL7+Sp8RMeIXSkvq0JHfDpWA1lIHaUWRy+4vlW07GkaFhTYHzIzB/GkD8wi5pu/pP8hwNI8', '2026-07-16 14:02:30'),
(7, 'Virtual', 'lVuJDVBq3ewkmED4urM6H4wXS42ey+bB59LthEgbWq3suGUzrQ5L/ClyEv+Xt/EtyYcSjgH+', '54HBKm86iXSxQAHTw+cg97VQcsrUyrCoBSw7z7nDURlN7TYuqZ7pS6bCAQyxT8Vo', '2026-03-16', 'Saiful Hilal, A.Md.Kom', '4', '8', '100', 'WfU+GTrRp0FkgreQtBI5iSHEauIZ0yl/ZqK61uPVRHnVBN+5jDn9V72toVoi1qgzheUOE0js', 'a+xuX9UJAanhGBOebZ1LiNdBsyo+XH88/mKRBGmZd9nfhKqho0VrUv3s1cA4yFNS+1AtKtlvOsyC9K+ShRdTY1yjxh/WJuUbQHJBullxmy+O1teasIOkbBbaawithcQ/iHa6gqKZ', '2026-07-16 14:11:06'),
(8, 'Virtual', 'J1clGFPdQ+SefRSiU1kkDuAcjNrk+HA1NgYICc1fNrROxGNGCY+5JKUN8c1qMvI3Was3tF6sgRo=', 'OWhSDbw1S9fg193MNZJ7rvGY2m+B3Q9u5YJLob3FHRQvXf7ZQYDqakrJeGoSApXh', '2026-07-16', 'Saiful Hilal, A.Md.Kom', '4', '4', '100', 'RgyIFV67Y0Rq8S7dYbHB8fR1UcS1vBiMWZYDgNDC6LdeFs1aIYhRrP2UhWScAUkvulQ2hl9ZGI9b/grl6UXX1SpqdQdsMcNm1ieC', 'szyqAUheqBJtmpTL/n5K0hrnC49jEbYTvaBsZhLzBKdeniVJcfSi4YquVHjOtU3DoiHS+1uupaKmnSHtX6ilU1tce5QmYSdHFJqm9KQlvB1fgOI411kHSwzGc7Atkma3RWA4peqn8DCDImZZB6jhs7nlAVUiqkYyW/k0Us+kBn+LIwyQhbqC1E8Yuivl3UVaydEpp5ydxmC2Pw==', '2026-07-16 14:14:43');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `nama_lengkap` varchar(255) NOT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama_lengkap`, `jabatan`, `email`, `password_hash`, `role_id`, `created_at`) VALUES
(9, 'Super Admin Pusdat', 'Pengelola Pusat Data', 'admin@kotabogor.go.id', '$2a$10$wE1Vp2b.YI/qH3N3qXoO5OMrD3YxQc/9o8Rk1V/o7c7u6e5a4b3c2', 1, '2026-07-16 08:10:21'),
(10, '/fW/kNIi0akszI0GfcosV+YqgrSKhfKFOX6WhWNguD2yZuS4FgcIjtkvszS5CQ==', 'Pranata Komputer Mahir', 'rp3r+/DYvakkVQeZmD6bqDSGFjTFTEEP7mwkHf4VX9aVMG8Fifhhr4BhMM5zoEJTwnQ6EBJG7w==', '$2a$10$ue4uRqUaYkYk9C1sou.7lugJBH4oJJR.KRmpXNIJyjt5p9KAMQwvG', 1, '2026-07-16 08:16:56'),
(11, 'ZGzZM5QsK9ONzY6BnSU2isEWOWkj3CwvGV/NnsChvfYujtLnCAMdrSS24aij6R/guDk=', 'Pranta Komputer Terampil', 'IEsOZu+oag1Sf6cINXpErJTGQd29/oMIPWQGsDS8rvmmAGFJHJdVPtYJCOtnRnm/PKX3hi0Ixg==', '$2a$10$5VNTOA7wM.0PP5qRWhxsneVQ7zDH3L8.cV1FK68vptm4I2tQsiQlG', 2, '2026-07-16 08:18:25'),
(12, 'SRnSK6raj9vaIorhJ+YNXfpaPlmPtTIESKcMvGHogPAjK+YgviqoNnEKvQ/3ulr9Wmw=', 'Pranata Komputer Ahli Muda', 'ApAw16ke0fjXRSAksLM0otwPXCanFCkbDDBTQ1/+WUJJfMHvlYJqT5iJvPN9lua5yiXK8H8=', '$2a$10$H7E6CAbr/VzyTf4G4uWt1.8ZWoPgyO3zbF2a5wI8I/lRPDvB3JEGG', 3, '2026-07-16 08:19:23');

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `module_id` int NOT NULL,
  `can_create` tinyint(1) DEFAULT '0',
  `can_read` tinyint(1) DEFAULT '0',
  `can_update` tinyint(1) DEFAULT '0',
  `can_delete` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ip_blocks`
--
ALTER TABLE `ip_blocks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ip_usages`
--
ALTER TABLE `ip_usages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `modules`
--
ALTER TABLE `modules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `piket_fasilitas`
--
ALTER TABLE `piket_fasilitas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `piket_laporan`
--
ALTER TABLE `piket_laporan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `piket_panel_listrik`
--
ALTER TABLE `piket_panel_listrik`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `piket_ups`
--
ALTER TABLE `piket_ups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `servers`
--
ALTER TABLE `servers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ip_blocks`
--
ALTER TABLE `ip_blocks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ip_usages`
--
ALTER TABLE `ip_usages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `logs`
--
ALTER TABLE `logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `modules`
--
ALTER TABLE `modules`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `piket_fasilitas`
--
ALTER TABLE `piket_fasilitas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `piket_laporan`
--
ALTER TABLE `piket_laporan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `piket_panel_listrik`
--
ALTER TABLE `piket_panel_listrik`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `piket_ups`
--
ALTER TABLE `piket_ups`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `servers`
--
ALTER TABLE `servers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `user_permissions`
--
ALTER TABLE `user_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
