---
layout: post
title: "雇用保険の失業等給付（基本手当）がいつ頃になるかがわかるWebサービス「雇用保険給付の相棒（Employmate）」をリリースしました🎉"
date:  2023-06-22 15:00:00 +0900
---

## どんなWebサービスなのか？

病気やケガで退職した後、働く意思がある60歳未満の人が、雇用保険の失業等給付（基本手当） [^5] を受けるまでの進行度（まだまだなのか、もう少しなのか）と、いつ頃から給付が受けられそうかがわかることで、次のような精神的な不安の軽減や、給付を受ける手続きを最小限にする目的のサービスです。

1. 数か月間の生計がどのようになるのかが大まかにわかる
2. 税金の軽減措置 [^1] の適用開始時期が大まかにわかる

[^1]: 税金の軽減措置は、雇用保険受給資格者証が交付された後に申請できるものがあります。

[^5]: [雇用保険の失業等給付](https://www.hellowork.mhlw.go.jp/insurance/insurance_summary.html) は、新しい仕事を探す際に、失業中の生活に心配がないように支給されます。

<a target="_blank" rel="noopener" href="https://employmate.jp">Webサービス「雇用保険給付の相棒（Employmate）」</a>は、病気やケガで退職した（する）時間的・精神的に余裕がない中、再就職を目指している方の状況や希望を教えてもらうことで、事情に合った雇用保険制度を調べます。

<a target="_blank" rel="noopener" href="https://employmate.jp">
  <img src="https://employmate.jp/ogp.png" alt="OGP用のアイキャッチ画像" width="144" height="144">
</a>
<p>
  <a target="_blank" rel="noopener" href="https://employmate.jp">https://employmate.jp</a>
</p>

### できること

<a target="_blank" rel="noopener" href="https://employmate.jp">Webサービス「雇用保険給付の相棒（Employmate）」</a>は、次の情報を段階的に提供します。

1. 残業時間や診断書の有無などを入力することで、ユーザーの事情を考慮した雇用保険制度（ハローワーク訪問時期・頻度と用意する書類）と大まかな初回の給付金振込予定日がわかります。
2. ユーザーの事情に合わせたチェックリストを提供し、ハローワーク訪問時期や頻度、用意する書類などが明確になります（会員登録が必要です）。
3. チェックリストを完了していくと、雇用保険受給資格者証を受け取るまでの進行度や、より正確な初回の給付金振込予定日がわかるようになります（会員登録が必要です）。

![病気やケガで退職した（する）状況や希望を教えてもらうことで、事情に合った雇用保険制度と初回の給付金受け取り予定日を示す動画](https://github.com/maeda-m/employmate/assets/943541/cfaffaef-3b08-4616-b52c-e986b5b42168)

### できないこと

雇用保険の失業等給付は、失業した人が仕事を探す間に生計を維持するための給付です。
いくつか分類があり、<a target="_blank" rel="noopener" href="https://employmate.jp">Webサービス「雇用保険給付の相棒（Employmate）」</a>では「一般被保険者に対する求職者給付」を対象範囲としますが、初回リリースにおいては、ほとんどの方が対象となる基本手当のみ対応しています。

次期リリース [^2] では次の手当に対応する予定です。

- 技能習得手当
- 寄宿手当
- 傷病手当

[^2]: https://github.com/users/maeda-m/projects/4/views/2

## 背景

私自身が2月末に退職して、3月6日からハローワークを何度か訪問し、正式に雇用保険受給資格者証を交付されたのが3月末でした。
それまでは基本手当の受給や国民健康保険料・税の軽減措置の申請ができない状況で、不安な日々を過ごしていました。

本来であれば3月中旬には雇用保険受給資格者証が交付されるはずだったのですが、
病気やケガで退職した場合は、雇用保険の要件を満たすための必要書類を入手・提出する必要があったりなど、雇用保険制度に対して知識不足な課題がありました。
現状対策としては、ハローワークの資料 [^3] や厚生労働省の資料 [^4] を熟読したり、ハローワークの窓口で雇用保険給付調査官に都度質問することで解決しました。

[^3]: https://www.hellowork.mhlw.go.jp/insurance/insurance_basicbenefit.html
[^4]: https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/koyou/koyouhoken/data/toriatsukai_youryou.html

以上の経験をもとに、同じ境遇の方の生活が少しでもよくなればと思い、Webサービスの開発をはじめました。

## 今後

今回は初回リリースで最小限の検証可能な範囲のみ開発していますが、今後は下図に示す手続きを支援できるように改善します。

![【図】雇用保険の基本手当受給資格決定までの最短手順](https://www.maeda-m.com/assets/images/20230311-carrier-reboot-figure-tb.svg)

## 開発

ソースコードは https://github.com/maeda-m/employmate で公開しています。不具合報告はもちろん、開発にご興味ある方は issue などでご連絡ください。

以下は、開発にご興味ある方に向けて、Webサービス「雇用保険給付の相棒（Employmate）」（以下、本サービスという）の技術的な内容を記載します。

### システム構成

本サービスは、ふつうの Ruby on Rails アプリケーションで、サーバーサイドレンダリングなHTMLと反応性が必要なところは [Hotwire（HTML-over-the-wire）](https://hotwired.dev/) の [Stimulus](https://stimulus.hotwired.dev/) で実現しています。そのため、フロントエンドのトランスコンパイルとバンドラーを使用していませんが、必要なライブラリは [importmap-rails](https://github.com/rails/importmap-rails/) 経由の [importmap](https://developer.mozilla.org/ja/docs/Web/HTML/Element/script/type/importmap) によって利用しています。

### アピールポイント

本サービスを、ふつうの Ruby on Rails アプリケーションと言ってしまうと味気ないので次の見出しで深掘りします。

1. HTML & CSS
2. レイヤーリング
3. 自動テスト

#### 1. HTML & CSS

本サービスは、最小限の文書構造のハイパーテキストになるようマークアップしています。言い換えると、見た目の装飾のために文書構造を複雑にしておらず、メンテナンスを容易にしています。
副次的効果は、自然にセマンティックな HTML になるため、利用しやすさ（スクリーンリーダーやキーボード操作）もよくなる点があります。

実現方法としては、マークアップされたタグの意味をもとに CSS が適用される [Pico.css - Minimal CSS Framework for semantic HTML](https://picocss.com/) を使用しています。
またボタンなどの部品は [ViewComponent](https://viewcomponent.org/) で再利用可能なカプセル化されたものとして管理しています。

#### 2. レイヤーリング

本サービスは、モデルに対応する Active Record が参照するパターンとしての [Active Record](https://bliki-ja.github.io/pofeaa/ActiveRecord/) を遵守します。

Patterns of Enterprise Application Architecture（以下、PoEAA という）における [レイヤーリング](https://www.oreilly.com/library/view/patterns-of-enterprise/0321127420/ch01.xhtml) として、プレゼンテーション、ドメイン、データソースという 3 つの主要な層からなるアーキテクチャは、上位層は下位層が定義するさまざまなサービスを利用しますが、下位層は上位層のことを知りません（ドメインとデータソースは、決してプレゼンテーションに依存しない）。

Ruby on Rails は [MVC](https://bliki-ja.github.io/pofeaa/ModelViewController/) アーキテクチャスタイルに沿った Web アプリケーションフレームワークで、各レイヤーに対応させると下表のようになります。

> ▼ 表. 3 つの主要レイヤーにおける MVC アーキテクチャスタイルの位置づけ

| レイヤー           | MVC アーキテクチャスタイル |
| ------------------ | -------------------------- |
| プレゼンテーション | ビューとコントローラ       |
| ドメイン           | モデル                     |
| データソース       | モデル                     |

Active Record は複雑（[complicated](https://scrapbox.io/kawasima/Complex%E3%81%A8Complicated)）で変化しやすいドメインロジックをドメインモデルを使って問題領域の語彙（primarily around the nouns in the domain）で Easy になるように整理した際、データベースと密接に結合した場合に役に立つパターンで、目的が複数にならないように Rich ではない Simple なドメインモデルが前提であるため、具体的な判断基準は次のとおりです。

- トランザクションスクリプトの置き場所として [サービスレイヤー](https://bliki-ja.github.io/pofeaa/ServiceLayer/) や [フォームクラス（テーブルを持たない Plain Old Ruby Object）](https://techracho.bpsinc.jp/hachi8833/2021_01_07/14738) を作りたくなったら、そもそもデータモデルとしてイベント系のエンティティ抽出ができていないのでは？と疑う
  - 言い換えると CRUD なコードをシンプルに書ける [REST](https://meetup-jp.toast.com/931) アーキテクチャスタイル（リソース自体が URL に表現され、リソースの行為が HTTP メソッドで表現できる）に対応した Ruby on Rails の機能を活用していること
- ビューで表現のため（単に親切にする表現などであること）にメソッドが必要なら [ViewComponent](https://viewcomponent.org/) や https://github.com/amatsuda/active_decorator を利用するが、業務に存在する表現はモデルに寄せたほうがいいため、HTML のビューと HTTP 以外（CLI の実行結果を表示するなど）のビューで共通して使うものはモデルに実装する
  - 言い換えるとモデルは上位層となるプレゼンテーション層にある HTML の詳細としてタグや構造を知らないこと

また Ruby on Rails の機能としてモデルに組み込まれているパターンがあるため、それらも活用します。

> ▼ 表.  Ruby on Rails のモデルに組み込まれている PoEAA のパターン

| PoEAA のパターン名| Ruby on Rails 上の実装|
| ----------------- | --------------------- |
| [Table Data Gateway](https://bliki-ja.github.io/pofeaa/TableDataGateway/)<br>[Row Data Gateway](https://bliki-ja.github.io/pofeaa/RowDataGateway/)                     | [core.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/core.rb)<br/>[persistence.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/persistence.rb)<br/>[relation/finder_methods.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/relation/finder_methods.rb)<br>[relation/query_methods.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/relation/query_methods.rb)<br>[relation/spawn_methods.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/relation/spawn_methods.rb)<br>[relation/calculations.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/relation/calculations.rb) |
| [Active Record](https://bliki-ja.github.io/pofeaa/ActiveRecord/) （ [ドメインモデル](https://bliki-ja.github.io/pofeaa/DomainModel/) ）| [validations/\*.rb](https://github.com/rails/rails/tree/7-0-stable/activerecord/lib/active_record/validations)<br>[callbacks.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/callbacks.rb)<br>[scoping/named.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/scoping/named.rb)<br>[enum.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/enum.rb) |
| [Foreign Key Mapping](https://bliki-ja.github.io/pofeaa/ForeignKeyMapping/)<br>[Association Table Mapping](https://bliki-ja.github.io/pofeaa/AssociationTableMapping/) | [associations.rb](https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/associations.rb) |

#### 3. 自動テスト

本サービスは、E2Eテストと単体テストを実施しています。

E2Eテストは [Turnip - Gherkin extension for RSpec](https://github.com/jnicklas/turnip) で要求レベルのテストシナリオを日本語で記述し、 [Playwright](https://playwright.dev/) を [Playwright driver for Capybara](https://github.com/YusukeIwaki/capybara-playwright-driver) 経由で操作してテストしています。

こういった要求レベルのテストは高価で、遅く、そして脆いと知られていますが、
本サービスにおいては、最小限の文書構造のハイパーテキストになるようマークアップした恩恵で高レベルのテストがしやすく、修正も容易になっています。

### おわりに

以上の技術的な内容は、学び直しを目的に入門した [FJORD BOOT CAMP（フィヨルドブートキャンプ）](https://bootcamp.fjord.jp/) の学習がきっかけ（メンターの方とのレビューによるコミュニケーションなども含む）で得たものです。

みなさんに感謝申し上げます。
Let's Enjoy Programming 🙌

---
