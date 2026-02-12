# 学習ログ(Daily Learning Log)  

## 2026-02-12（木）  
  - CCNA学習  
  - Vercelを初めて利用するため利用方法の学習  

## 2026-02-10（火）  
  - CCNA学習
  - 明日からはVercelで静的ウェブサイトをデプロイできるようにする

## 2026-02-09（月）  
  - CCNA学習  
  - NATゲートウェイを深堀り  

## 2026-02-07（土）  
  - circleciの設定ファイルを修正
    - 最後S3にファイルを自動アップロードがエラー解消できず  

## 2026-02-06（金）  
  - circleciの設定ファイルを修正  
    -  エラーで進めず  

## 2026-02-04（水）  
  - circleciの設定ファイルを修正  
  - circleciの環境変数を設定  
  - 次はS3+CloudFrontの自動化を実行

## 2026-02-03（火）  
  - cirlceciの設定ファイルを作成  
    - メインの設定ファイルの下に複数のプロジェクトの設定ファイルを置けるよう作成  
    - S3 + CloudFrontの設定ファイルを作成直し  

## 2026-02-02（月）  
  - S3 + CloudFrontのセキュリティ強化（最小権限のIAMユーザー）  
  - Githubリポジトリのファイル構造を検討  

## 2026-02-01（日）  
  - VPC関連のCloudFormationテンプレートを基にコンソールからリソース作成  
  - 作成リソース:EIP NatGateway

## 2026-01-31（土）  
  - VPC関連のCloudFormationテンプレートを基にコンソールからリソース作成  
  - 作成リソース:VPC Subnet(public protected private)  InternetGateway RouteTable VPCendpoint

## 2026-01-29(木)  
  - S3 + CloudFrontを自動化するためのCiecleCiの設定ファイルを作成
  - 構文チェック->cloudformationの実行->S3にアップロードの自動化を記載

## 2026-01-28（水）  
  - S3 + CloudFrontを自動化するためのCiecleCiの設定ファイルを作成  
  
## 2026-01-25(日)  
  - VPC関連のCloudformationのテンプレートから内容を分解  
  - Subnet、NatGateway
  
## 2026-01-24（土）  
  - VPC関連のCloudformationのテンプレートから内容を分解
  
## 2026-01-23（金）  
  - S3 + CloudFrontをCloudFormationでlaCの作成  
  - OACで静的ウェブサイトを公開するlaCの作成  
  
## 2026-01-22（木）  
### ハンズオン: AWS:S3 + CloudFront プロジェクト  
  - S3バケット作成  
  - パブリックアクセスブロックをオン  
  - 静的ウェブサイトを作成->index.html  
  - S3バケットをオリジンにCloudFront作成  
  - OAC設定  