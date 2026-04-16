---
layout: page
title: プライバシーポリシー
description: "プライバシーポリシーについてご確認いただけます。"
permalink: /privacy-policy/
last_updated: "2026年4月15日"
---

{{ site.developer.name }}（以下「当社」）は、{{ site.app.name }}（以下「本アプリ」）におけるユーザーのプライバシーを尊重し、個人情報の保護に努めます。本プライバシーポリシーは、本アプリが収集する情報、その使用方法、およびユーザーの権利について説明します。

## 1. 収集する情報

{% if site.privacy.data_collection and site.privacy.data_collection.size > 0 %}
本アプリでは、以下の情報を収集する場合があります。

{% for item in site.privacy.data_collection %}
### {{ item.type }}

{{ item.description }}

{% endfor %}
{% else %}
本アプリでは、ユーザーの個人情報を収集しません。
{% endif %}

## 2. 情報の使用目的

収集した情報は、以下の目的で使用します。

- アプリの機能提供および改善
- 技術的な問題の特定と解決
- ユーザーサポートの提供
- 法令に基づく対応

## 3. 情報の第三者提供

当社は、以下の場合を除き、ユーザーの情報を第三者に提供しません。

- ユーザーの同意がある場合
- 法令に基づく場合
- 人の生命、身体または財産の保護のために必要がある場合

{% if site.privacy.third_party_services and site.privacy.third_party_services.size > 0 %}
### 利用している第三者サービス

本アプリでは、以下の第三者サービスを利用しています。各サービスのプライバシーポリシーもご確認ください。

{% for service in site.privacy.third_party_services %}
- [{{ service.name }}]({{ service.url }}){:target="_blank" rel="noopener"}
{% endfor %}
{% endif %}

## 4. データの保管と保護

収集したデータは適切なセキュリティ対策を講じて保管します。ただし、インターネット上の通信やデータ保管において、完全なセキュリティを保証することはできません。

## 5. お子様のプライバシー

本アプリは、13歳未満のお子様から意図的に個人情報を収集しません。13歳未満のお子様の個人情報が収集されたことが判明した場合、速やかに削除いたします。

## 6. プライバシーポリシーの変更

当社は、必要に応じて本プライバシーポリシーを変更することがあります。変更した場合は、本ページにて通知します。

## 7. お問い合わせ

本プライバシーポリシーに関するお問い合わせは、以下までご連絡ください。

- メール: [{{ site.app.support_email }}](mailto:{{ site.app.support_email }})

---

施行日: {{ site.privacy.effective_date }}
