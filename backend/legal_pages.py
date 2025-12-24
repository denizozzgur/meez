"""
Legal pages HTML templates for Meez App
These are served at /privacy-policy and /terms-of-service
"""

from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter()

COMMON_STYLES = """
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        background: linear-gradient(180deg, #0F172A 0%, #1E293B 100%);
        color: #E2E8F0;
        line-height: 1.6;
        min-height: 100vh;
        padding: 40px 20px;
    }
    .container {
        max-width: 800px;
        margin: 0 auto;
        background: rgba(30, 41, 59, 0.5);
        border-radius: 16px;
        padding: 40px;
        border: 1px solid rgba(255, 255, 255, 0.1);
    }
    h1 {
        font-size: 32px;
        font-weight: 700;
        margin-bottom: 8px;
        color: #FFFFFF;
    }
    .updated {
        color: #64748B;
        font-size: 12px;
        margin-bottom: 32px;
    }
    h2 {
        font-size: 18px;
        font-weight: 600;
        color: #FFFFFF;
        margin-top: 32px;
        margin-bottom: 12px;
    }
    p {
        color: #94A3B8;
        font-size: 14px;
        margin-bottom: 12px;
    }
    ul {
        list-style: none;
        padding-left: 16px;
    }
    li {
        color: #94A3B8;
        font-size: 14px;
        margin-bottom: 8px;
        position: relative;
    }
    li::before {
        content: "•";
        position: absolute;
        left: -16px;
        color: #22D3EE;
    }
    .highlight {
        color: #FFFFFF;
        font-weight: 600;
    }
    a {
        color: #22D3EE;
        text-decoration: none;
    }
    a:hover {
        text-decoration: underline;
    }
    .logo {
        text-align: center;
        margin-bottom: 24px;
    }
    .logo span {
        font-size: 48px;
    }
</style>
"""

@router.get("/privacy-policy", response_class=HTMLResponse)
async def privacy_policy():
    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - Meez</title>
    {COMMON_STYLES}
</head>
<body>
    <div class="container">
        <div class="logo"><span>✨</span></div>
        <h1>Privacy Policy</h1>
        <p class="updated">Last updated: December 2025</p>
        
        <h2>1. Information We Collect</h2>
        <p>When you use Meez, we collect minimal information necessary to provide our services:</p>
        <ul>
            <li><span class="highlight">Images you upload:</span> Photos you choose to convert into stickers are processed by our AI systems. We do not permanently store your original images.</li>
            <li><span class="highlight">Generated stickers:</span> Stickers you create may be stored temporarily to enable sharing and export features.</li>
            <li><span class="highlight">Usage data:</span> We collect anonymous usage statistics to improve our app, such as feature usage frequency and crash reports.</li>
            <li><span class="highlight">Device information:</span> Basic device identifiers for app functionality and analytics.</li>
        </ul>
        
        <h2>2. How We Use Your Information</h2>
        <p>We use collected information to:</p>
        <ul>
            <li>Generate AI-powered stickers from your photos</li>
            <li>Enable sticker sharing to WhatsApp and other platforms</li>
            <li>Improve app performance and user experience</li>
            <li>Provide customer support</li>
            <li>Process subscription payments (handled by Apple)</li>
        </ul>
        
        <h2>3. Data Sharing</h2>
        <p>We do not sell your personal data. We may share data with:</p>
        <ul>
            <li><span class="highlight">AI Service Providers:</span> Your images are processed by third-party AI services to generate stickers. These services are bound by strict data protection agreements.</li>
            <li><span class="highlight">Analytics Providers:</span> Anonymous usage data helps us improve the app.</li>
            <li><span class="highlight">Payment Processors:</span> Apple handles all subscription payments. We never see your payment details.</li>
        </ul>
        
        <h2>4. Community Content</h2>
        <p>When you share sticker packs to the Community Board:</p>
        <ul>
            <li>Your pack becomes publicly visible to other users</li>
            <li>An anonymous username is generated for display</li>
            <li>You can report inappropriate content using the report button</li>
            <li>We reserve the right to remove content that violates our guidelines</li>
        </ul>
        
        <h2>5. Data Retention</h2>
        <ul>
            <li>Uploaded images are processed and deleted within 24 hours</li>
            <li>Generated stickers are retained while your account is active</li>
            <li>You can delete your packs from the History tab at any time</li>
            <li>Community content may be retained for moderation purposes</li>
        </ul>
        
        <h2>6. Your Rights</h2>
        <p>You have the right to:</p>
        <ul>
            <li>Access your data</li>
            <li>Delete your sticker packs</li>
            <li>Opt out of analytics (contact support)</li>
            <li>Request account deletion</li>
        </ul>
        
        <h2>7. Children's Privacy</h2>
        <p>Meez is not intended for children under 13. We do not knowingly collect data from children under 13. If you believe a child has provided us with personal information, please contact us.</p>
        
        <h2>8. Security</h2>
        <p>We implement industry-standard security measures to protect your data. However, no method of transmission over the internet is 100% secure.</p>
        
        <h2>9. Changes to This Policy</h2>
        <p>We may update this policy from time to time. We will notify you of significant changes through the app.</p>
        
        <h2>10. Contact Us</h2>
        <p>If you have questions about this Privacy Policy, please contact us at:</p>
        <p><a href="mailto:support@meez.app">support@meez.app</a></p>
    </div>
</body>
</html>
"""

@router.get("/terms-of-service", response_class=HTMLResponse)
async def terms_of_service():
    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service - Meez</title>
    {COMMON_STYLES}
</head>
<body>
    <div class="container">
        <div class="logo"><span>✨</span></div>
        <h1>Terms of Service</h1>
        <p class="updated">Last updated: December 2025</p>
        
        <h2>1. Acceptance of Terms</h2>
        <p>By downloading, installing, or using Meez ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the App.</p>
        
        <h2>2. Description of Service</h2>
        <p>Meez is an AI-powered sticker creation app that allows you to:</p>
        <ul>
            <li>Create personalized stickers from photos using artificial intelligence</li>
            <li>Export stickers to messaging apps like WhatsApp</li>
            <li>Browse and share sticker packs in the Community Board</li>
            <li>Subscribe for unlimited sticker creation</li>
        </ul>
        
        <h2>3. User Accounts</h2>
        <ul>
            <li>You are responsible for maintaining the confidentiality of your device and account</li>
            <li>You agree to accept responsibility for all activities that occur under your account</li>
            <li>You must be at least 13 years old to use this service</li>
        </ul>
        
        <h2>4. Subscription Terms</h2>
        <ul>
            <li>Meez offers subscription plans for unlimited access</li>
            <li>Payment is charged to your Apple ID account</li>
            <li>Subscriptions auto-renew unless cancelled 24 hours before the end of the current period</li>
            <li>You can manage and cancel subscriptions in your App Store account settings</li>
            <li>No refunds are provided for partial subscription periods</li>
        </ul>
        
        <h2>5. Free Trial</h2>
        <ul>
            <li>New users may receive a free trial period</li>
            <li>The free trial includes limited sticker generations</li>
            <li>After the trial ends, a subscription is required for continued use</li>
            <li>If you cancel during the trial, you won't be charged</li>
        </ul>
        
        <h2>6. User Content</h2>
        <p>You retain ownership of images you upload. By using the App, you grant us a license to process your images for sticker creation. You are solely responsible for the content you create and share.</p>
        <p>You must not upload content that:</p>
        <ul>
            <li>Infringes on intellectual property rights</li>
            <li>Contains illegal, harmful, or offensive material</li>
            <li>Violates the privacy of others</li>
            <li>Contains malware or viruses</li>
        </ul>
        
        <h2>7. Community Guidelines</h2>
        <p>When sharing to the Community Board:</p>
        <ul>
            <li>You agree that your content may be visible to all users</li>
            <li>You must not share offensive, illegal, or inappropriate content</li>
            <li>We reserve the right to remove any content without notice</li>
            <li>Repeated violations may result in account termination</li>
        </ul>
        
        <h2>8. Intellectual Property</h2>
        <ul>
            <li>The App, including its design, features, and content, is protected by copyright and other intellectual property laws</li>
            <li>You may not copy, modify, or distribute the App without permission</li>
            <li>AI-generated stickers you create are yours to use personally</li>
        </ul>
        
        <h2>9. Limitation of Liability</h2>
        <ul>
            <li>The App is provided "as is" without warranties of any kind</li>
            <li>We are not liable for any indirect, incidental, or consequential damages</li>
            <li>Our total liability shall not exceed the amount you paid for the service in the past 12 months</li>
        </ul>
        
        <h2>10. Termination</h2>
        <ul>
            <li>We may terminate or suspend your access at any time for violations of these terms</li>
            <li>You may stop using the App at any time</li>
            <li>Upon termination, your right to use the App ceases immediately</li>
        </ul>
        
        <h2>11. Changes to Terms</h2>
        <p>We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms.</p>
        
        <h2>12. Contact</h2>
        <p>For questions about these Terms of Service:</p>
        <p><a href="mailto:support@meez.app">support@meez.app</a></p>
    </div>
</body>
</html>
"""
