---
layout: page
title: User Privacy Choices / ユーザープライバシー選択
description: "SmooZip のプライバシー設定と選択肢 / Privacy choices and settings for SmooZip"
permalink: /user-privacy-choices/
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

<h1>ユーザープライバシー選択</h1>
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">最終更新日：2026年4月21日</p>

<p>{{ site.app.name }} では、ユーザーのプライバシーを尊重し、データの取り扱いについて透明性を確保しています。以下に、ユーザーが選択・管理できるプライバシー設定についてご説明します。</p>

{% if site.privacy.data_collection %}
{% assign optional_items = site.privacy.data_collection | where_exp: "item", "item.required != true" %}
{% if optional_items.size > 0 %}
<h2>データ収集のオプトアウト</h2>
{% for item in optional_items %}
<h3>{{ item.type }}</h3>
<p>{{ item.description }}</p>
<p>この機能はオプションであり、アプリの設定画面からオフにすることができます。</p>
{% endfor %}
{% endif %}
{% endif %}

<h2>Google アカウント連携の管理</h2>
<p>本アプリは Gmail / Google Drive との連携に Google 認証トークンを使用します。以下の方法で連携を解除できます。</p>
<ul>
  <li><strong>アプリ内から：</strong>設定 → Google アカウント連携解除</li>
  <li><strong>Google アカウントから：</strong><a href="https://myaccount.google.com/permissions" target="_blank">Google アカウントのアプリ連携設定</a> からアクセス権を取り消す</li>
</ul>

<h2>データの削除</h2>
<p>ユーザーデータの削除を希望される場合は、以下の方法で対応できます。</p>
<ul>
  <li><strong>送付履歴：</strong>アプリ内の履歴画面から手動で削除できます。また、設定した日数（デフォルト 30 日）が経過すると自動的に削除されます。</li>
  <li><strong>送信先リスト・送信テンプレート：</strong>アプリ内の各管理画面から個別に、または一括で削除できます。</li>
  <li><strong>すべてのデータ：</strong>アプリを端末からアンインストールすることで、端末上のデータはすべて削除されます。</li>
  <li><strong>Google Drive 上のファイル：</strong>Google Drive の <code>SmooZip</code> フォルダから通常の操作で削除できます。</li>
</ul>

<h2>お問い合わせ</h2>
<p>プライバシーに関するご質問やご要望は、以下までご連絡ください。</p>
<ul>
  <li>メール: <a href="mailto:{{ site.app.support_email }}">{{ site.app.support_email }}</a></li>
</ul>
<p>詳細なデータ取り扱いについては、<a href="{{ '/privacy-policy/' | relative_url }}">プライバシーポリシー</a>もご参照ください。</p>

</div>

<!-- ============================================================ -->
<!-- English -->
<!-- ============================================================ -->
<div class="lang-en" style="display:none;">

<h1>User Privacy Choices</h1>
<p style="color:#6e6e73;font-size:0.9em;margin-bottom:32px;">Last updated: April 21, 2026</p>

<p>{{ site.app.name }} is committed to respecting your privacy and being transparent about how your data is handled. Below you will find the privacy settings and choices available to you.</p>

{% if site.privacy.data_collection %}
{% assign optional_items_en = site.privacy.data_collection | where_exp: "item", "item.required != true" %}
{% if optional_items_en.size > 0 %}
<h2>Opt Out of Data Collection</h2>
{% for item in optional_items_en %}
<h3>{{ item.type }}</h3>
<p>{{ item.description }}</p>
<p>This feature is optional and can be turned off from the App's settings screen.</p>
{% endfor %}
{% endif %}
{% endif %}

<h2>Managing Your Google Account Connection</h2>
<p>The App uses a Google authentication token to connect with Gmail and Google Drive. You can disconnect at any time using either of the following methods:</p>
<ul>
  <li><strong>Within the App:</strong> Settings → Disconnect Google Account</li>
  <li><strong>From Google:</strong> Revoke access via your <a href="https://myaccount.google.com/permissions" target="_blank">Google Account's third-party app settings</a></li>
</ul>

<h2>Data Deletion</h2>
<p>You can delete your data using the following methods:</p>
<ul>
  <li><strong>Send History:</strong> Delete records manually from the History screen within the App. Records are also automatically deleted after the number of days you configure (default: 30 days).</li>
  <li><strong>Recipient List / Send Templates:</strong> Delete individually or in bulk from the corresponding management screens within the App.</li>
  <li><strong>All Data:</strong> Uninstalling the App from your device removes all locally stored data.</li>
  <li><strong>Files on Google Drive:</strong> Delete directly from the <code>SmooZip</code> folder in your Google Drive using standard Drive operations.</li>
</ul>

<h2>Contact</h2>
<p>For any questions or requests regarding your privacy, please contact us:</p>
<ul>
  <li>Email: <a href="mailto:{{ site.app.support_email }}">{{ site.app.support_email }}</a></li>
</ul>
<p>For full details on how we handle your data, please refer to our <a href="{{ '/privacy-policy/' | relative_url }}">Privacy Policy</a>.</p>

</div>
