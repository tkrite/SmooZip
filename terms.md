---
layout: page
title: Terms of Service / 利用規約
description: "Smoozip の利用規約 / Terms of Service for Smoozip"
permalink: /terms/
last_updated: "2026年4月7日"
---

<div class="lang-switch" style="margin-bottom:32px;">
  <a href="#" onclick="showLang('ja'); return false;" style="color:#0071e3;text-decoration:none;margin-right:12px;">日本語</a>
  <a href="#" onclick="showLang('en'); return false;" style="color:#0071e3;text-decoration:none;">English</a>
</div>

<script>
function showLang(lang) {
  document.querySelectorAll('.lang-ja').forEach(function(el){ el.style.display = lang === 'ja' ? 'block' : 'none'; });
  document.querySelectorAll('.lang-en').forEach(function(el){ el.style.display = lang === 'en' ? 'block' : 'none'; });
}
window.addEventListener('load', function() {
  var userLang = navigator.language || 'ja';
  showLang(userLang.startsWith('ja') ? 'ja' : 'en');
});
</script>

<!-- ============================================================ -->
<!-- 日本語 -->
<!-- ============================================================ -->
<div class="lang-ja">

<h1>利用規約</h1>
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">最終更新日：2026年4月7日</p>

<p>本利用規約（以下「本規約」）は、Tkrite inc.（以下「開発者」）が提供する Smoozip（以下「本アプリ」）の利用条件を定めるものです。本アプリをダウンロードまたは使用することにより、ユーザーは本規約に同意したものとみなします。</p>

<h2>1. サービスの内容</h2>
<p>本アプリは、macOS 向けのファイル圧縮・暗号化アプリケーションです。AES-256 暗号化による ZIP ファイルの作成、パスワード管理、および Gmail を通じたファイル送付機能を提供します。開発者は、事前の通知なく、サービスの内容を変更、追加、または廃止する場合があります。</p>

<h2>2. 利用条件</h2>
<p>ユーザーは、以下の条件に従って本アプリを利用するものとします。</p>
<ul>
  <li>法令および公序良俗に反する行為をしないこと</li>
  <li>開発者または第三者の権利を侵害しないこと</li>
  <li>本アプリの運営を妨害しないこと</li>
  <li>リバースエンジニアリング、逆コンパイル、逆アセンブルを行わないこと</li>
  <li>本アプリを違法なファイルの送受信・隠蔽の目的で使用しないこと</li>
</ul>

<h2>3. 知的財産権</h2>
<p>本アプリに関する著作権、商標権その他の知的財産権は、開発者または正当な権利を有する第三者に帰属します。本規約は、ユーザーに対して本アプリを利用するための限定的・非独占的・譲渡不可のライセンスを付与するものであり、それ以上の権利を付与するものではありません。</p>

<h2>4. 免責事項</h2>
<ul>
  <li>開発者は、本アプリの完全性、正確性、確実性、有用性等について、いかなる保証も行いません。</li>
  <li>開発者は、本アプリの利用に起因してユーザーに生じた損害について、開発者に故意または重過失がある場合を除き、一切の責任を負いません。</li>
  <li>開発者は、本アプリの中断、停止、変更等によりユーザーに生じた損害について、責任を負いません。</li>
  <li>Gmail を利用したファイル送付における通信障害・送信失敗・誤送信等について、開発者は責任を負いません。</li>
  <li>ユーザーが設定したパスワードの紛失・漏洩に起因する損害について、開発者は責任を負いません。</li>
</ul>

<h2>5. Apple App Store</h2>
<p>本アプリは Apple App Store を通じて配布される macOS 専用アプリケーションです。購入・返金等の手続きについては、<a href="https://www.apple.com/legal/internet-services/itunes/jp/" target="_blank">Apple のサービス利用規約</a>に従ってください。</p>

<h2>6. 個人情報の取り扱い</h2>
<p>ユーザーの個人情報の取り扱いについては、開発者の<a href="{{ '/privacy-policy/' | relative_url }}">プライバシーポリシー</a>に従います。</p>

<h2>7. 規約の変更</h2>
<p>開発者は、必要と判断した場合には、本規約を変更できるものとします。変更後の利用規約は、本ページに掲載された時点から効力を生じるものとします。重要な変更がある場合は、「最終更新日」を更新します。</p>

<h2>8. 準拠法・管轄裁判所</h2>
<p>本規約の解釈にあたっては、日本法を準拠法とします。本アプリに関して紛争が生じた場合には、東京地方裁判所を第一審の専属的合意管轄裁判所とします。</p>

<h2>9. お問い合わせ</h2>
<p>本規約に関するお問い合わせは、以下までご連絡ください。</p>
<p><a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a></p>

</div>

<!-- ============================================================ -->
<!-- English -->
<!-- ============================================================ -->
<div class="lang-en" style="display:none;">

<h1>Terms of Service</h1>
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">Last updated: April 7, 2026</p>

<p>These Terms of Service ("Terms") govern your use of Smoozip ("the App"), a macOS application developed by Tkrite inc. ("the Developer"). By downloading or using the App, you agree to these Terms. If you do not agree, please discontinue use of the App.</p>

<h2>1. About the App</h2>
<p>Smoozip is a macOS file compression and encryption application. It provides AES-256 encrypted ZIP file creation, password management, and file delivery via Gmail. The Developer reserves the right to modify, add, or discontinue features at any time without prior notice.</p>

<h2>2. Acceptable Use</h2>
<p>You agree to use the App only in accordance with the following conditions:</p>
<ul>
  <li>You will not violate any applicable laws or regulations</li>
  <li>You will not infringe the rights of the Developer or any third party</li>
  <li>You will not interfere with or disrupt the App's operation</li>
  <li>You will not reverse engineer, decompile, or disassemble the App</li>
  <li>You will not use the App for the purpose of transmitting or concealing illegal files</li>
</ul>

<h2>3. Intellectual Property</h2>
<p>All copyrights, trademarks, and other intellectual property rights relating to the App belong to the Developer or their respective rightful owners. These Terms grant you a limited, non-exclusive, non-transferable license to use the App, and nothing herein grants you any additional rights.</p>

<h2>4. Disclaimer of Warranties</h2>
<ul>
  <li>The Developer makes no warranties of any kind regarding the completeness, accuracy, reliability, or fitness for a particular purpose of the App.</li>
  <li>The Developer shall not be liable for any damages arising from your use of the App, except in cases of willful misconduct or gross negligence by the Developer.</li>
  <li>The Developer shall not be liable for any damages arising from interruption, suspension, or modification of the App.</li>
  <li>The Developer is not responsible for communication failures, delivery failures, or misdirected emails when sending files via Gmail.</li>
  <li>The Developer is not responsible for any damages resulting from the loss or disclosure of passwords set by the user.</li>
</ul>

<h2>5. Apple App Store</h2>
<p>The App is distributed exclusively through the Apple App Store as a macOS application. For purchases and refunds, please refer to <a href="https://www.apple.com/legal/internet-services/itunes/" target="_blank">Apple's Terms of Service</a>.</p>

<h2>6. Privacy</h2>
<p>Your personal information is handled in accordance with the Developer's <a href="{{ '/privacy-policy/' | relative_url }}">Privacy Policy</a>.</p>

<h2>7. Changes to These Terms</h2>
<p>The Developer may update these Terms at any time. Updated Terms take effect as soon as they are posted on this page. The "Last updated" date will be revised when material changes are made.</p>

<h2>8. Governing Law and Jurisdiction</h2>
<p>These Terms shall be governed by and construed in accordance with the laws of Japan. Any disputes arising in connection with the App shall be subject to the exclusive jurisdiction of the Tokyo District Court as the court of first instance.</p>

<h2>9. Contact</h2>
<p>For questions about these Terms, please contact:</p>
<p><a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a></p>

</div>
