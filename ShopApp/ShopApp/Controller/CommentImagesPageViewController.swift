//
//  CommentImagesPageViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 08.07.2022.
//

import UIKit

protocol CommentImagesPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

class CommentImagesPageViewController: UIPageViewController {

    weak var walkthroughDelegate: CommentImagesPageViewControllerDelegate?

    private var images = [UIImage]()
    private var currentIndex = 0

    func setImages(images: [UIImage]) { self.images = images }
    func getCurrentIndex() -> Int { return self.currentIndex }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }

        dataSource = self
        delegate = self
    }
}

extension CommentImagesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as? ProductImagesContainerViewController)?.getIndex() else {
            return UIViewController()
        }

        index -= 1
        return contentViewController(at: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as? ProductImagesContainerViewController)?.getIndex() else {
            return UIViewController()
        }

        index += 1
        return contentViewController(at: index)
    }

    func contentViewController(at index: Int) -> ProductImagesContainerViewController? {
        if index < 0 || index >= images.count {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let storyboard = UIStoryboard(name: "ProductsByCategory", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "ImagesProductViewController") as? ProductImagesContainerViewController {
            pageContentViewController.configure(index: index, image: images[index])
            return pageContentViewController
        }

        return nil
    }
}

extension CommentImagesPageViewController: UIPageViewControllerDelegate {
    // The method will be automatically called after a gesture-driven transition completes
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? ProductImagesContainerViewController {
                currentIndex = contentViewController.getIndex()
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.getIndex())
            }
        }
    }
}
