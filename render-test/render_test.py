import os
from urllib.request import urlopen
from selenium import webdriver

SCREENSHOTS_PATH = './screenshots'

SCREENSHOTS = [
    ('/', 'home.png'),
    ('/about-us', 'about.png'),
    ('/donate', 'donate.png'),
    ('/email', 'email.png'),
    ('/canary', 'canary.png'),
]


def check_connectivity(url):
    print(f'checking connectivity for {url}')
    resp = urlopen(url)
    if resp.status != 200:
        raise Exception(f'Request for {url} got HTTP status {resp.status}')
    resp.close()


def run_test(driver, url):
    os.makedirs(SCREENSHOTS_PATH, exist_ok=True)
    for url_path, img_path in SCREENSHOTS:
        print(f'requesting {url_path}')
        driver.get(url + url_path)
        save_screenshot(driver, os.path.join(SCREENSHOTS_PATH, img_path))


def setup():
    options = webdriver.ChromeOptions()
    options.add_argument('--no-sandbox')
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    return webdriver.Chrome(options=options)


def save_screenshot(driver, path):
    print(f'saving screenshot to {path}')
    # Ref: https://stackoverflow.com/a/52572919/
    original_size = driver.get_window_size()
    required_width = driver.execute_script('return document.body.parentNode.scrollWidth')
    required_height = driver.execute_script('return document.body.parentNode.scrollHeight')
    driver.set_window_size(required_width, required_height)
    # driver.save_screenshot(path)  # has scrollbar
    driver.find_element_by_tag_name('body').screenshot(path)  # avoids scrollbar
    driver.set_window_size(original_size['width'], original_size['height'])


def main():
    url = os.getenv('SITE_URL')
    if not url:
        print('ERROR: SITE_URL is not defined')
        return 1

    check_connectivity(url)

    driver = setup()
    try:
        run_test(driver, url)
    finally:
        driver.quit()


if __name__ == '__main__':
    main()

