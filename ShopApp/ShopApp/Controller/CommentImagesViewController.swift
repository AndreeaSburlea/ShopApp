//
//  CommentImagesViewController.swift
//  ShopApp
//
//  Created by Viviana Mesaros on 08.07.2022.
//

import UIKit

class CommentImagesViewController: UIViewController {

    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var cancelButton: UIButton!

    private var images = [UIImage]()

    func setImages(images: [UIImage]) { self.images = images}

    private var walkthroughPageViewController: CommentImagesPageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pageControl.numberOfPages = self.images.count
    }

    // MARK: - Prepare - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? CommentImagesPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
            pageViewController.setImages(images: images)
        }
    }

    // MARK: - Close Action
    @IBAction private func closeAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }


    func updateUI() {
        if let index = walkthroughPageViewController?.getCurrentIndex() {
            pageControl.currentPage = index
        }
    }
}

extension CommentImagesViewController: CommentImagesPageViewControllerDelegate {
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
