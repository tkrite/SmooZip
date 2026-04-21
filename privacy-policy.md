---
layout: page
title: Privacy Policy / プライバシーポリシー
description: "SmooZip のプライバシーポリシー / Privacy Policy for SmooZip"
permalink: /privacy-policy/
last_updated: "2026年4月21日"
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
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">最終更新日：2026年4月21日</p>

<p>SmooZip（以下「本アプリ」）は、Tkrite inc.（以下「開発者」）が提供する macOS 向けファイル圧縮・暗号化アプリケーションです。本ポリシーは、本アプリがどのような個人情報を取り扱うか、その法的根拠、およびユーザーの皆様の権利について説明します。</p>
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
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Google 認証トークン（Gmail / Google Drive 共通）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内 Keychain（暗号化）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Gmail 経由のメール送信および Google Drive へのファイルアップロード機能を提供するため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">契約の履行（Art. 6(1)(b)）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">「Google アカウント連携解除」操作または本アプリのアンインストール時まで</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送付先メールアドレス・ファイル名・送信日時・送信ステータス</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内ローカルデータベース（Core Data）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送付履歴の表示および自動削除機能のため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">正当な利益（Art. 6(1)(f)）／ユーザーの同意</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">ユーザーが設定した日数（デフォルト 30 日）経過後に自動削除</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送信先リスト（メールアドレス・氏名・会社名・電話番号・グループ名）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内ローカルデータベース（Core Data）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送信先の再利用・一括送信・CSV インポート機能を提供するため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">ユーザーの同意（Art. 6(1)(a)）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">ユーザーが手動で削除するまで／本アプリのアンインストール時まで</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送信テンプレート（件名・本文のひな形）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内ローカルデータベース（Core Data）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">メール送信時のテンプレート再利用機能を提供するため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">ユーザーの同意（Art. 6(1)(a)）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">ユーザーが手動で削除するまで／本アプリのアンインストール時まで</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">暗号化 ZIP のパスワード（送付履歴ごとに保管）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">デバイス内 Keychain（暗号化）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">送付後のパスワード別送・再確認機能を提供するため</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">契約の履行（Art. 6(1)(b)）</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">対応する送付履歴の削除時（自動削除日数経過時を含む）に自動削除</td>
  </tr>
</table>

<p style="margin-top:12px;">上記のデータはすべてユーザーのデバイス上にのみ保存されます。開発者のサーバーやクラウドサービスにデータが転送されることはありません（Gmail / Google Drive API を通じた Google へのデータ送信については第3項をご参照ください）。</p>

<h2>3. Google API（Gmail / Google Drive）の利用とデータの送信</h2>
<p>本アプリは Google の各種 API を通じて、メール送信および大容量ファイル共有の機能を提供します。いずれも機能を有効化した場合にのみ Google のサーバーと通信します。</p>

<h3 style="font-size:1.05em;margin-top:24px;">3-1. Gmail API によるメール送信</h3>
<p>Gmail 連携を有効にした場合、メール送信時に送付先メールアドレス・件名・本文・添付ファイルが Google のサーバーに送信されます。これは Gmail を利用したメール送信に不可欠な処理です。</p>
<ul>
  <li>使用する OAuth 2.0 スコープは <code>gmail.send</code> のみです</li>
  <li>メールの読み取り・削除・連絡先へのアクセスは行いません</li>
</ul>
<p><strong>パスワードの別送機能について：</strong>「パスワードを別メールで送付する」機能を有効にした場合、設定した暗号化パスワードがメール本文に含まれた状態で Gmail 経由で送信されます。このパスワードは Gmail のサーバーを経由するため、Google のメールインフラ上に保存されることをご理解ください。この機能を使用する際は、送信前に確認ダイアログが表示されます。セキュリティ上の懸念がある場合は、パスワードを別の手段（電話・SMS など）で相手に伝えることをお勧めします。</p>

<h3 style="font-size:1.05em;margin-top:24px;">3-2. Google Drive API によるファイル共有</h3>
<p>Google Drive 連携を有効にした場合、圧縮・暗号化済みのアーカイブファイルを Google Drive にアップロードし、共有リンクを生成することができます（Gmail の添付容量制限を超える大容量ファイルの共有等を想定した機能です）。</p>
<ul>
  <li>使用する OAuth 2.0 スコープは <code>drive.file</code> のみです</li>
  <li><code>drive.file</code> スコープは <strong>「本アプリが作成したファイル」のみ</strong>にアクセス可能です。ユーザーの既存の Google Drive 内ファイル・フォルダを読み取る、一覧する、変更することはできません</li>
  <li>本アプリは Google Drive 上に <code>SmooZip</code> フォルダを作成し、その配下に送信ごとのサブフォルダを生成してアーカイブファイルをアップロードします</li>
  <li>アップロードされるのはユーザーが明示的に送信対象として選択したファイル（圧縮・暗号化済み）のみです</li>
</ul>
<p><strong>共有リンクのモードについて：</strong>ユーザーは送信時に以下の共有モードを選択できます。</p>
<ul>
  <li><strong>リンクを知っている全員：</strong>該当サブフォルダに「リンクを知っている全員」が閲覧可能な共有権限が付与されます</li>
  <li><strong>特定のメールアドレスに共有：</strong>指定したメールアドレスの Google アカウントにのみ共有権限が付与されます</li>
  <li><strong>共有リンクを付与しない（デフォルト）：</strong>共有権限は付与されず、受信者はオーナーへアクセスリクエストを行う必要があります</li>
</ul>
<p>付与した共有権限はユーザー自身が Google Drive から随時確認・変更・取消できます。本アプリが共有権限の付与に関与するのは、送信操作の時点のみです。</p>

<h3 style="font-size:1.05em;margin-top:24px;">3-3. 共通事項</h3>
<ul>
  <li>認証トークンはデバイスの Keychain に保存され、開発者を含む第三者がアクセスすることはできません</li>
  <li>トークンは Google 公式 SDK（Google Sign-In for iOS）により管理され、iCloud 同期は無効化されています</li>
  <li>Google によるデータの取り扱いについては <a href="https://policies.google.com/privacy" target="_blank">Google プライバシーポリシー</a> をご参照ください</li>
</ul>
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
  <li><strong>AES-256 暗号化：</strong>ZIP / 7-Zip ファイルを業界標準の AES-256 で暗号化します</li>
  <li><strong>Keychain 保護：</strong>Google 認証トークンおよび暗号化 ZIP のパスワードは macOS Keychain に保存され、デバイスのロック解除時のみアクセス可能です。iCloud 同期は無効化されています</li>
  <li><strong>App Sandbox：</strong>macOS の App Sandbox によりファイルアクセスが制限されています</li>
  <li><strong>暗号学的に安全なパスワード生成：</strong>パスワード自動生成機能は OS 提供の暗号学的に安全な乱数生成器（<code>SecRandomCopyBytes</code>）を使用します</li>
</ul>

<h2>7. データの削除</h2>
<ul>
  <li><strong>送付履歴：</strong>設定した日数（デフォルト 30 日）経過後に自動削除されます。また、アプリ内の履歴画面から手動で削除することもできます。履歴の削除時には、対応する暗号化パスワード（Keychain 内）も同時に削除されます。アプリをアンインストールすると、すべての履歴データが削除されます。</li>
  <li><strong>送信先リスト・送信テンプレート：</strong>アプリ内の各管理画面から個別に、または一括で削除できます。</li>
  <li><strong>Google 認証トークン（Gmail / Google Drive）：</strong>アプリ内の「設定 → Google アカウント連携解除」から削除できます。また、<a href="https://myaccount.google.com/permissions" target="_blank">Google アカウントのアプリ連携設定</a> からもアクセス権を取り消すことができます。</li>
  <li><strong>Google Drive にアップロード済みのファイル：</strong>ユーザー自身の Google Drive の <code>SmooZip</code> フォルダ配下から、Google Drive の通常の操作により削除できます（本アプリからの削除機能は提供していません）。</li>
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
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">Last updated: April 21, 2026</p>

<p>SmooZip ("the App") is a macOS file compression and encryption application developed by Tkrite inc. ("the Developer"). This Privacy Policy explains what personal information the App handles, the legal basis for processing, and your rights as a user.</p>
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
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Google authentication token (shared for Gmail / Google Drive)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Device Keychain (encrypted)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To provide email sending via Gmail and file upload to Google Drive</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Performance of a contract (Art. 6(1)(b))</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Until "Disconnect Google Account" or App uninstall</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Recipient email, file name, send date/time, delivery status</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Local database on device (Core Data)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To display send history and support auto-deletion</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Legitimate interests (Art. 6(1)(f)) / User consent</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Automatically deleted after the number of days set by the user (default: 30 days)</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Recipient list (email, name, company, phone, group)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Local database on device (Core Data)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To support recipient reuse, batch sending, and CSV import</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">User consent (Art. 6(1)(a))</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Until manual deletion by the user / App uninstall</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Send templates (subject and body presets)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Local database on device (Core Data)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To allow reuse of email content when sending</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">User consent (Art. 6(1)(a))</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Until manual deletion by the user / App uninstall</td>
  </tr>
  <tr>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Encryption passwords for sent archives (per history entry)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Device Keychain (encrypted)</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">To support separate password delivery and later reference</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Performance of a contract (Art. 6(1)(b))</td>
    <td style="border:1px solid #d2d2d7;padding:8px 12px;">Automatically deleted when the corresponding history entry is removed (including by auto-deletion)</td>
  </tr>
</table>

<p style="margin-top:12px;">All of the above data is stored solely on the user's device. No data is transmitted to the Developer's servers or to any cloud service operated by the Developer. (Data transmitted to Google via the Gmail / Google Drive APIs is described in Section 3.)</p>

<h2>3. Use of Google APIs (Gmail / Google Drive) and Data Transmission</h2>
<p>The App uses Google APIs to provide email sending and large-file sharing functionality. The App only communicates with Google's servers when these features are enabled by the user.</p>

<h3 style="font-size:1.05em;margin-top:24px;">3-1. Gmail API for Email Delivery</h3>
<p>When Gmail integration is enabled, the recipient's email address, subject, body, and attached file are transmitted to Google's servers at the time of sending. This is essential to the email sending functionality.</p>
<ul>
  <li>The only OAuth 2.0 scope used is <code>gmail.send</code></li>
  <li>The App does not read, delete, or access your emails or contacts</li>
</ul>
<p><strong>Separate Password Email Feature:</strong> When the "Send password in a separate email" option is enabled, the encryption password you set is included in plain text in the body of a separate email sent via Gmail. Please be aware that this password passes through and is stored on Google's mail infrastructure. A confirmation dialog is shown before each such transmission. If you have security concerns, we recommend sharing the password through an alternative channel (e.g., phone call or SMS) instead.</p>

<h3 style="font-size:1.05em;margin-top:24px;">3-2. Google Drive API for File Sharing</h3>
<p>When Google Drive integration is enabled, the App can upload the compressed (and optionally encrypted) archive to your Google Drive and generate a shareable link. This feature is intended for sharing large files that exceed Gmail's attachment size limit.</p>
<ul>
  <li>The only OAuth 2.0 scope used is <code>drive.file</code></li>
  <li>The <code>drive.file</code> scope grants access <strong>only to files created by the App itself</strong>. The App cannot read, list, or modify any pre-existing files or folders in your Google Drive</li>
  <li>The App creates a <code>SmooZip</code> folder on your Google Drive and uploads each archive into a timestamped subfolder beneath it</li>
  <li>Only files that you explicitly select and send through the App (after compression / encryption) are uploaded</li>
</ul>
<p><strong>Sharing link modes:</strong> At the time of sending, you can choose one of the following:</p>
<ul>
  <li><strong>Anyone with the link:</strong> The subfolder is shared with view access to anyone who has the link</li>
  <li><strong>Specific email address:</strong> The subfolder is shared only with the Google account of the specified email address</li>
  <li><strong>No link / Request access (default):</strong> No sharing permission is granted; the recipient must request access from you as the owner</li>
</ul>
<p>You can review, modify, or revoke any sharing permissions at any time from Google Drive itself. The App only interacts with sharing permissions at the moment of sending.</p>

<h3 style="font-size:1.05em;margin-top:24px;">3-3. Common Items</h3>
<ul>
  <li>Authentication tokens are stored in your device's Keychain and are not accessible to the Developer or any third party</li>
  <li>Tokens are managed by Google's official SDK (Google Sign-In for iOS) and iCloud sync of Keychain items used by the App is disabled</li>
  <li>For details on how Google handles this data, please refer to the <a href="https://policies.google.com/privacy" target="_blank">Google Privacy Policy</a></li>
</ul>
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
  <li><strong>AES-256 Encryption:</strong> ZIP / 7-Zip archives are encrypted using industry-standard AES-256</li>
  <li><strong>Keychain Protection:</strong> Google authentication tokens and encryption passwords are stored in the macOS Keychain and are accessible only when the device is unlocked. iCloud sync of these items is disabled</li>
  <li><strong>App Sandbox:</strong> File access is restricted by macOS App Sandbox</li>
  <li><strong>Cryptographically Secure Password Generation:</strong> The password generator uses the operating system's cryptographically secure random number generator (<code>SecRandomCopyBytes</code>)</li>
</ul>

<h2>7. Data Deletion</h2>
<ul>
  <li><strong>Send History:</strong> Automatically deleted after the number of days you configure (default: 30 days). You can also delete records manually from the History screen within the App. When a history entry is deleted, the corresponding encryption password in the Keychain is removed at the same time. Uninstalling the App removes all history data.</li>
  <li><strong>Recipient List / Send Templates:</strong> Can be deleted individually or in bulk from the corresponding management screens within the App.</li>
  <li><strong>Google Authentication Token (Gmail / Google Drive):</strong> Can be removed via Settings → Disconnect Google Account within the App. You can also revoke access at any time from your <a href="https://myaccount.google.com/permissions" target="_blank">Google Account's third-party app settings</a>.</li>
  <li><strong>Files Uploaded to Google Drive:</strong> Can be deleted directly from the <code>SmooZip</code> folder in your own Google Drive using standard Drive operations. (The App does not provide a Drive deletion feature.)</li>
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
