
# 概要
ECSを使ったAPIサーバのテンプレートプロジェクト。
* APIサーバは、PythonのFast APIで動作する。
* APIサーバは、DBと接続する前提であり、MySQLを利用する。
* ECSは、Fargate タイプを使用。
* ECSタスクは、指定したVPCのパブリックサブネットに配置する。
* デプロイは、CodeDeployを使った Blue/Green デプロイメントで行う。
* アプリケーションのログはfirelensを使って指定したS3バケットに送信される。
* WIP: テストデプロイ時に、Lambdaで作ったnewmanスクリプトを実行し、APIのE2Eテストが行われる。
* Autoscalingの設定により、サービスの数が変動する。
