---
layout: page
title: Privacy Policy / プライバシーポリシー
description: "SecureZip のプライバシーポリシー / Privacy Policy for SecureZip"
permalink: /privacy-policy/
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

<h1>プライバシーポリシー</h1>
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">最終更新日：2026年4月7日</p>

<p>SecureZip（以下「本アプリ」）は、Tkrite inc.（以下「開発者」）が提供する macOS 向けファイル圧縮・暗号化アプリケーションです。本ポリシーは、本アプリがどのような個人情報を取り扱うか、その法的根拠、およびユーザーの皆様の権利について説明します。</p>
<p>本アプリをご利用いただくことで、本ポリシーへの同意とみなします。同意いただけない場合は、本アプリのご利用をお控えください。</p>

<h2>1. データ管理者</h2>
<p>本アプリにおける個人データの管理者（データコントローラー）は以下の通りです。</p>
<ul>
  <li><strong>名称：</strong>Tkrite inc.</li>
  <li><strong>連絡先：</strong><a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a></li>
</ul>
<p>個人情報の取り扱いに関するご質問・ご要望は上記メールアドレスまでお問い合わせください。</p>

<h2>2. 収集する個人情報と利用目的・法的根拠</h2>
<p>本アプリが収集・保存する個人情報は以下のみです。</p>

<table style="border-collapse:collapse;width:100%;margin-top:8px;">
  <tr>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">情報の種類</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">保存場所</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">利用目的</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">法的根拠（GDPR）</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">保持期間</th>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Gmail 認証トークン</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内 Keychain（暗号化）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Gmail 経由のメール送信機能を提供するため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">契約の履行（Art. 6(1)(b)）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">「Gmail 連携解除」操作または本アプリのアンインストール時まで</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送付先メールアドレス・ファイル名・送信日時</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内ローカルデータベース（Core Data）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送付履歴の表示および自動削除機能のため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">正当な利益（Art. 6(1)(f)）／ユーザーの同意</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">ユーザーが設定した日数（デフォルト 30 日）経過後に自動削除</td>
  </tr>
</table>

<p style="margin-top:12px;">上記のデータはすべてユーザーのデバイス上にのみ保存されます。開発者のサーバーやクラウドサービスにデータが転送されることはありません。</p>

<h2>3. Gmail API の利用とデータの送信</h2>
<p>本アプリは Gmail API を通じてメール送信を行います。メール送信時には、送付先メールアドレスおよび添付ファイルが Google のサーバーに送信されます。これは Gmail を利用したメール送信に不可欠な処理です。</p>
<ul>
  <li>使用する OAuth 2.0 スコープは <code>gmail.send</code> のみです</li>
  <li>メールの読み取り・削除・連絡先へのアクセスは行いません</li>
  <li>認証トークンはデバイスの Keychain に保存され、開発者を含む第三者がアクセスすることはできません</li>
  <li>Google によるデータの取り扱いについては <a href="https://policies.google.com/privacy" target="_blank">Google プライバシーポリシー</a> をご参照ください</li>
</ul>
<p><strong>パスワードの別送機能について：</strong>「パスワードを別メールで送付する」機能を有効にした場合、設定した暗号化パスワードがメール本文に含まれた状態で Gmail 経由で送信されます。このパスワードは Gmail のサーバーを経由するため、Google のメールインフラ上に保存されることをご理解ください。この機能を使用する際は、送信前に確認ダイアログが表示されます。セキュリティ上の懸念がある場合は、パスワードを別の手段（電話・SMS など）で相手に伝えることをお勧めします。</p>
<p>本アプリの Google API の利用は <a href="https://developers.google.com/terms/api-services-user-data-policy" target="_blank">Google API Services User Data Policy</a> に準拠しています。Google から取得したデータを、Google の利用規約で許可された範囲を超えて使用・保存・共有することはありません。</p>

<h2>4. 収集しない情報</h2>
<p>本アプリは以下の情報を一切収集しません。</p>
<ul>
  <li>アナリティクス・利用統計データ</li>
  <li>広告識別子</li>
  <li>位置情報</li>
  <li>圧縮・解凍するファイルの内容</li>
  <li>クラッシュレポート（開発者への自動送信なし）</li>
</ul>

<h2>5. 第三者への情報提供</h2>
<p>本アプリは、ユーザーの個人情報を第三者に<strong>販売しません</strong>。また、本ポリシーに定める場合（Gmail API によるメール送信）を除き、第三者に提供・共有することもありません。</p>

<h2>6. セキュリティ</h2>
<p>本アプリは以下の技術的措置によりデータを保護しています。</p>
<ul>
  <li><strong>AES-256 暗号化：</strong>ZIP ファイルを業界標準の AES-256 で暗号化します</li>
  <li><strong>Keychain 保護：</strong>認証トークンは macOS Keychain に保存され、デバイスのロック解除時のみアクセス可能です</li>
  <li><strong>App Sandbox：</strong>macOS の App Sandbox によりファイルアクセスが制限されています</li>
</ul>

<h2>7. データの削除</h2>
<ul>
  <li><strong>送付履歴：</strong>設定した日数（デフォルト 30 日）経過後に自動削除されます。また、アプリ内の履歴画面から手動で削除することもできます。アプリをアンインストールすると、すべての履歴データが削除されます。</li>
  <li><strong>Gmail 認証トークン：</strong>アプリ内の「設定 → Gmail 連携解除」から削除できます。</li>
</ul>

<h2>8. ユーザーの権利</h2>
<p>お客様の居住地域に応じて、以下の権利が適用されます。</p>

<p><strong>▶ EU / EEA 居住者（GDPR）</strong></p>
<ul>
  <li><strong>アクセス権：</strong>保有する個人データのコピーを請求できます</li>
  <li><strong>訂正権：</strong>不正確なデータの修正を要求できます</li>
  <li><strong>消去権（忘れられる権利）：</strong>特定の条件下でデータの削除を要求できます</li>
  <li><strong>処理制限権：</strong>処理の一時停止を要求できます</li>
  <li><strong>データポータビリティ権：</strong>機械読み取り可能な形式でデータを受け取ることができます</li>
  <li><strong>異議申立権：</strong>正当な利益に基づく処理に異議を申し立てることができます</li>
  <li><strong>監督機関への申立権：</strong>お住まいの国のデータ保護機関（DPA）に苦情を申し立てる権利があります（例：日本の個人情報保護委員会、ドイツの BfDI など）</li>
</ul>

<p><strong>▶ カリフォルニア州居住者（CCPA）</strong></p>
<ul>
  <li><strong>情報開示請求権：</strong>収集された個人情報の種類・利用目的の開示を請求できます</li>
  <li><strong>削除権：</strong>収集された個人情報の削除を要求できます</li>
  <li><strong>販売オプトアウト権：</strong>本アプリは個人情報を販売しないため、このオプトアウトの実質的な行使は不要です</li>
  <li><strong>差別禁止：</strong>上記権利の行使を理由に差別的な扱いを受けることはありません</li>
</ul>

<p>上記権利を行使される場合は、<a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a> までご連絡ください。本アプリのデータはすべてデバイス上に保存されるため、多くの場合、アプリ内の機能（履歴削除・連携解除）から直接対応することが可能です。</p>

<h2>9. お子様のプライバシー（COPPA）</h2>
<p>本アプリは 13 歳未満のお子様を対象としておらず、意図的に 13 歳未満の方の個人情報を収集することはありません。13 歳未満のお子様が本アプリを使用していることが判明した場合、または保護者の方がそのようなデータの削除を希望される場合は、<a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a> までご連絡ください。速やかに対応いたします。</p>

<h2>10. ポリシーの変更</h2>
<p>本ポリシーは必要に応じて更新されることがあります。重要な変更がある場合は、このページの「最終更新日」を更新します。定期的にご確認いただくことをお勧めします。本アプリは個人開発のため、メールによる変更通知は現時点では提供していません。</p>

<h2>11. お問い合わせ</h2>
<p>本ポリシーに関するご質問・データに関するご要望は以下までお問い合わせください。</p>
<p><a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a></p>

</div>

<!-- ============================================================ -->
<!-- English -->
<!-- ============================================================ -->
<div class="lang-en" style="display:none;">

<h1>Privacy Policy</h1>
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">Last updated: April 7, 2026</p>

<p>SecureZip ("the App") is a macOS file compression and encryption application developed by Tkrite inc. ("the Developer"). This Privacy Policy explains what personal information the App handles, the legal basis for processing, and your rights as a user.</p>
<p>By using the App, you agree to this Privacy Policy. If you do not agree, please discontinue use of the App.</p>

<h2>1. Data Controller</h2>
<p>The data controller for personal data processed by the App is:</p>
<ul>
  <li><strong>Name:</strong> Tkrite inc.</li>
  <li><strong>Contact:</strong> <a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a></li>
</ul>
<p>For any questions or requests regarding your personal data, please contact us at the address above.</p>

<h2>2. Information We Collect, How We Use It, and Legal Basis</h2>
<p>The App collects and stores only the following personal information:</p>

<table style="border-collapse:collapse;width:100%;margin-top:8px;">
  <tr>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">Data Type</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">Storage Location</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">Purpose</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">Legal Basis (GDPR)</th>
    <th style="border:1px solid #d2d2d7;padding:8px 12px;background:#f5f5f7;text-align:left;">Retention Period</th>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Gmail authentication token</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Device Keychain (encrypted)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To provide email sending functionality via Gmail</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Performance of a contract (Art. 6(1)(b))</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Until "Disconnect Gmail" or App uninstall</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Recipient email address, file name, send date/time</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Local database on device (Core Data)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To display send history and support auto-deletion</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Legitimate interests (Art. 6(1)(f)) / User consent</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Automatically deleted after the number of days set by the user (default: 30 days)</td>
  </tr>
</table>

<p style="margin-top:12px;">All data is stored solely on the user's device. No data is transmitted to the Developer's servers or any cloud service operated by the Developer.</p>

<h2>3. Use of Gmail API and Data Transmission</h2>
<p>The App uses the Gmail API to send emails. When sending, the recipient's email address and the attached file are transmitted to Google's servers. This is essential to the email sending functionality.</p>
<ul>
  <li>The only OAuth 2.0 scope used is <code>gmail.send</code></li>
  <li>The App does not read, delete, or access your emails or contacts</li>
  <li>Authentication tokens are stored in your device's Keychain and are not accessible to the Developer or any third party</li>
  <li>For details on how Google handles this data, please refer to the <a href="https://policies.google.com/privacy" target="_blank">Google Privacy Policy</a></li>
</ul>
<p><strong>Separate Password Email Feature:</strong> When the "Send password in a separate email" option is enabled, the encryption password you set is included in plain text in the body of a separate email sent via Gmail. Please be aware that this password passes through and is stored on Google's mail infrastructure. A confirmation dialog is shown before each such transmission. If you have security concerns, we recommend sharing the password through an alternative channel (e.g., phone call or SMS) instead.</p>
<p>The App's use of Google APIs complies with the <a href="https://developers.google.com/terms/api-services-user-data-policy" target="_blank">Google API Services User Data Policy</a>. Data obtained from Google APIs is not used, stored, or shared beyond what is permitted by Google's Terms of Service.</p>

<h2>4. Information We Do Not Collect</h2>
<p>The App does not collect any of the following:</p>
<ul>
  <li>Analytics or usage statistics</li>
  <li>Advertising identifiers</li>
  <li>Location data</li>
  <li>Contents of files being compressed or decompressed</li>
  <li>Crash reports (no automatic reporting to the Developer)</li>
</ul>

<h2>5. Sharing of Information</h2>
<p>The App does <strong>not sell</strong> your personal information. We do not share or provide your personal information to any third party, except as necessary to transmit emails via the Gmail API as described in Section 3.</p>

<h2>6. Security</h2>
<p>The App uses the following technical measures to protect your data:</p>
<ul>
  <li><strong>AES-256 Encryption:</strong> ZIP files are encrypted using industry-standard AES-256</li>
  <li><strong>Keychain Protection:</strong> Authentication tokens are stored in the macOS Keychain, accessible only when the device is unlocked</li>
  <li><strong>App Sandbox:</strong> File access is restricted by macOS App Sandbox</li>
</ul>

<h2>7. Data Deletion</h2>
<ul>
  <li><strong>Send History:</strong> Automatically deleted after the number of days you configure (default: 30 days). You can also delete records manually from the History screen within the App. Uninstalling the App removes all history data.</li>
  <li><strong>Gmail Authentication Token:</strong> Can be removed via Settings → Disconnect Gmail within the App.</li>
</ul>

<h2>8. Your Privacy Rights</h2>
<p>Depending on your region, the following rights may apply to you.</p>

<p><strong>▶ EU / EEA Residents (GDPR)</strong></p>
<ul>
  <li><strong>Right of Access:</strong> You may request a copy of the personal data we hold about you</li>
  <li><strong>Right to Rectification:</strong> You may request correction of inaccurate data</li>
  <li><strong>Right to Erasure ("Right to be Forgotten"):</strong> You may request deletion of your data under certain conditions</li>
  <li><strong>Right to Restriction of Processing:</strong> You may request that processing be temporarily suspended</li>
  <li><strong>Right to Data Portability:</strong> You may receive your data in a machine-readable format</li>
  <li><strong>Right to Object:</strong> You may object to processing based on legitimate interests</li>
  <li><strong>Right to Lodge a Complaint:</strong> You have the right to lodge a complaint with your local data protection authority (e.g., ICO in the UK, CNIL in France, BfDI in Germany)</li>
</ul>

<p><strong>▶ California Residents (CCPA)</strong></p>
<ul>
  <li><strong>Right to Know:</strong> You may request disclosure of what personal information is collected and how it is used</li>
  <li><strong>Right to Delete:</strong> You may request deletion of personal information we have collected</li>
  <li><strong>Right to Opt-Out of Sale:</strong> We do not sell personal information, so there is no opt-out required in practice</li>
  <li><strong>Right to Non-Discrimination:</strong> We will not discriminate against you for exercising any of these rights</li>
</ul>

<p>To exercise any of these rights, please contact us at <a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a>. Since all App data is stored on your device, many requests can be fulfilled directly using in-app features (history deletion, disconnect Gmail).</p>

<h2>9. Children's Privacy (COPPA)</h2>
<p>The App is not directed at children under the age of 13, and we do not knowingly collect personal information from children under 13. If you believe a child under 13 has used the App or that such data has been collected, please contact us at <a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a> and we will promptly delete any such information.</p>

<h2>10. Changes to This Policy</h2>
<p>This policy may be updated from time to time. When material changes are made, the "Last updated" date at the top of this page will be revised. We encourage you to review this policy periodically. As this is an individually developed app, email notification of changes is not currently provided.</p>

<h2>11. Contact</h2>
<p>For questions about this policy or requests regarding your personal data, please contact:</p>
<p><a href="mailto:{{ site.developer.email }}">{{ site.developer.email }}</a></p>

</div>
