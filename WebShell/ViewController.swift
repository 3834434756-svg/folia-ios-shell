import UIKit
import WebKit
import AVFoundation

/// 壳容器：全屏 WKWebView 加载 Folia 在线版（社区部署 folia-ce.cn），
/// 界面、歌词动画等全部由 Web 应用自身渲染，App 只提供原生容器与后台音频能力。
class ViewController: UIViewController, WKNavigationDelegate {

    // 在线版地址。若要指向自己部署的官方 Web 版，改这里即可。
    private let targetURL = "https://folia-ce.cn/"

    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private var retryButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        configureAudioSession()
        setupWebView()
        setupLoadingIndicator()
        load()
    }

    // MARK: - 后台音频
    /// 让 HTML5 音频遵循 playback 会话，切后台/锁屏后继续播放。
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true, options: [])
        } catch {
            print("[Folia] AVAudioSession 配置失败: \(error.localizedDescription)")
        }
    }

    // MARK: - WebView
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        // 视频内联播放（不强制全屏）
        config.allowsInlineMediaPlayback = true
        // 允许无用户手势自动播放（音乐/歌词动画需要）
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        // 画中画（部分浏览器控件会用到）
        config.allowsPictureInPictureMediaPlayback = true
        // websiteDataStore 用默认，保留登录态/设置等本地数据
        config.websiteDataStore = .default()

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.backgroundColor = .black
        webView.scrollView.bounces = false              // 去掉顶部橡皮筋，更像原生 App
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupLoadingIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .lightGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func load() {
        retryButton?.removeFromSuperview()
        retryButton = nil
        guard let url = URL(string: targetURL) else { return }
        activityIndicator.startAnimating()
        webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showRetry(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showRetry(error)
    }

    private func showRetry(_ error: Error) {
        guard retryButton == nil else { return }
        let button = UIButton(type: .system)
        button.setTitle("加载失败，点此重试\n\(error.localizedDescription)", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.tintColor = .white
        button.addTarget(self, action: #selector(load), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
        retryButton = button
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
