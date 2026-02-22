abstract class ProfileConfig {

  static const empty = '';
  static const undefined = '未設定';
  static const undefinedJob = Job(category: '未設定', name: '未設定');
  static final defaultDateTime = DateTime(2026, 1, 1);

  static const List<String> prefectures = [
    '北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県',
    '茨城県','栃木県','群馬県','埼玉県','千葉県','東京都','神奈川県',
    '新潟県','富山県','石川県','福井県','山梨県','長野県',
    '岐阜県','静岡県','愛知県','三重県',
    '滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県',
    '鳥取県','島根県','岡山県','広島県','山口県',
    '徳島県','香川県','愛媛県','高知県',
    '福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県',
    '沖縄県',
  ];

  static const List<JobCategory> jobCategories = [
    JobCategory(
      name: 'IT・テクノロジー',
      jobs: [
        'フロントエンド(Web)エンジニア',
        'モバイルアプリエンジニア',
        'バックエンドエンジニア',
        'フルスタックエンジニア',
        'インフラエンジニア',
        'ネットワークエンジニア',
        'セキュリティエンジニア',
        'データサイエンティスト',
        'AI・機械学習エンジニア',
        'プロダクトマネージャー（PM）',
        'QA・テストエンジニア',
        'ITコンサルタント',
        'その他IT系',
      ],
    ),
    JobCategory(
      name: 'クリエイティブ・デザイン',
      jobs: [
        'グラフィックデザイナー',
        'Webデザイナー',
        'UI/UXデザイナー',
        '動画制作・編集',
        '写真家・フォトグラファー',
        'コピーライター',
        'イラストレーター',
        'アートディレクター',
        'ゲームクリエイター',
        'その他クリエイティブ系',
      ],
    ),
    JobCategory(
      name: '営業・マーケティング',
      jobs: [
        '営業（法人向け）',
        '営業（個人向け）',
        'インサイドセールス',
        'フィールドセールス',
        'マーケティング（デジタル）',
        'マーケティング（広告・PR）',
        'カスタマーサクセス',
        'セールスマネージャー',
        '事業開発（BizDev）',
        'その他営業・マーケティング',
      ],
    ),
    JobCategory(
      name: '総務・人事・事務',
      jobs: [
        '総務',
        '人事',
        '労務',
        '経理',
        '財務',
        '秘書',
        '事務職（一般）',
        '経営企画',
        '広報・PR',
        '法務',
        'その他総務・事務系',
      ],
    ),
    JobCategory(
      name: '製造・技術・建設',
      jobs: [
        '製造オペレーター',
        '機械設計',
        '電気・電子技術者',
        '建築士',
        '施工管理',
        '土木技術者',
        '品質管理・QC',
        '研究開発（R&D）',
        '生産管理',
        'その他技術系',
      ],
    ),
    JobCategory(
      name: '医療・福祉',
      jobs: [
        '医師',
        '看護師',
        '薬剤師',
        '介護職',
        'リハビリスタッフ',
        '保健師・助産師',
        '医療事務',
        'その他医療・福祉',
      ],
    ),
    JobCategory(
      name: '教育・公務',
      jobs: [
        '教員（小中高）',
        '教員（大学・専門学校）',
        '塾講師・家庭教師',
        '国家公務員',
        '地方公務員',
        '警察・消防',
        'その他教育・公務',
      ],
    ),
    JobCategory(
      name: '自営業・フリーランス',
      jobs: [
        '自営業（店舗経営）',
        '自営業（サービス業）',
        '自営業（製造業）',
        '農業経営',
        'フリーランス（IT・開発）',
        'フリーランス（デザイン・クリエイティブ）',
        'フリーランス（ライティング・編集）',
        'フリーランス（コンサルタント）',
        'その他自営業・フリーランス',
      ],
    ),
    JobCategory(
      name: '学生',
      jobs: [
        '大学生',
        '専門学校生',
        '高校生',
        'その他学生',
      ],
    ),
    JobCategory(
      name: '主婦・主夫',
      jobs: [
        '専業主婦・主夫',
        'パート・アルバイト',
      ],
    ),
    JobCategory(
      name: '無職・その他',
      jobs: [
        '求職中',
        'その他',
      ],
    ),
  ];
}

class Job {
  final String category;
  final String name;
  const Job({required this.category, required this.name});
}

class JobCategory {
  final String name;
  final List<String> jobs;

  const JobCategory({required this.name, required this.jobs});
}